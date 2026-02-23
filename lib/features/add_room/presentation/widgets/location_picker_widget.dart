import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/storage/location_service.dart';

class LocationPickerWidget extends ConsumerStatefulWidget {
  final Function(LocationCoords, String) onLocationSelect;
  final LocationCoords? defaultLocation;
  final String title;
  final String? userId;

  const LocationPickerWidget({
    super.key,
    required this.onLocationSelect,
    this.defaultLocation,
    this.title = 'Select Location',
    this.userId,
  }) : super();

  @override
  ConsumerState<LocationPickerWidget> createState() =>
      _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends ConsumerState<LocationPickerWidget> {
  LocationCoords? _confirmedLocation;
  String _confirmedAddress = '';
 
  LocationCoords? _draftLocation;
  String _draftAddress = '';

  bool _permissionGranted = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String _searchError = '';

  @override
  void initState() {
    super.initState();
    _confirmedLocation = widget.defaultLocation;
    _draftLocation = widget.defaultLocation;
    _confirmedAddress = widget.defaultLocation?.address ?? '';
    _draftAddress = _confirmedAddress;
    _checkPermission();
    _hydrateAddress();
  }

  @override
  void didUpdateWidget(LocationPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultLocation != oldWidget.defaultLocation) {
      setState(() {
        _confirmedLocation = widget.defaultLocation;
        _draftLocation = widget.defaultLocation;
        _confirmedAddress = widget.defaultLocation?.address ?? '';
        _draftAddress = _confirmedAddress;
      });
      _hydrateAddress();
    }
  }

  Future<void> _checkPermission() async {
    final hasPermission = await LocationService.checkLocationPermission(
      widget.userId,
    );
    setState(() {
      _permissionGranted = hasPermission;
    });
  }

  Future<void> _hydrateAddress() async {
    if (_confirmedLocation == null) return;

    if (_confirmedAddress.isNotEmpty &&
        _confirmedLocation!.address != null &&
        _confirmedLocation!.address!.isNotEmpty) {
      return;
    }

    final address = await LocationService.reverseGeocode(
      _confirmedLocation!.latitude,
      _confirmedLocation!.longitude,
    );
    setState(() {
      _confirmedAddress = address;
      if (_draftLocation?.latitude == _confirmedLocation?.latitude &&
          _draftLocation?.longitude == _confirmedLocation?.longitude) {
        _draftAddress = address;
      }
    });
  }

  Future<void> _updateDraftLocation(
    double latitude,
    double longitude, {
    StateSetter? setModalState,
  }) async {
    final address = await LocationService.reverseGeocode(latitude, longitude);
    if (!mounted) return;
    if (setModalState != null) {
      setModalState(() {
        _draftLocation = LocationCoords(
          latitude: latitude,
          longitude: longitude,
          address: address,
        );
        _draftAddress = address;
      });
      return;
    }
    setState(() {
      _draftLocation = LocationCoords(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _draftAddress = address;
    });
  }

  Future<void> _searchAddress(
    Function(VoidCallback) setModalState,
    MapController mapController,
  ) async {
    if (_searchQuery.trim().isEmpty) {
      setModalState(() {
        _searchError = 'Enter a location to search';
      });
      return;
    }

    setModalState(() {
      _searchError = '';
      _isSearching = true;
    });

    try {
      final result = await LocationService.geocodeAddress(_searchQuery.trim());
      if (!mounted) return;

      if (result == null) {
        setModalState(() {
          _searchError =
              'No results found.';
          _isSearching = false;
        });
        return;
      }

      setModalState(() {
        _searchError = '';
        _draftLocation = result;
        _draftAddress = result.address ?? 'Selected location';
        _isSearching = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        mapController.move(LatLng(result.latitude, result.longitude), 15);
      });
    } catch (e) {
      setModalState(() {
        _searchError = 'Search error: $e';
        _isSearching = false;
      });
    }
  }

  Future<void> _confirmLocation() async {
    if (_draftLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_draftAddress.isEmpty) {
      await _updateDraftLocation(
        _draftLocation!.latitude,
        _draftLocation!.longitude,
      );
    }

    setState(() {
      _confirmedLocation = _draftLocation;
      _confirmedAddress = _draftAddress;
    });

    widget.onLocationSelect(_confirmedLocation!, _confirmedAddress);
    Navigator.pop(context);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Location confirmed')));
  }

  void _onMapTapped(LatLng position, StateSetter setModalState) {
    _updateDraftLocation(
      position.latitude,
      position.longitude,
      setModalState: setModalState,
    );
  }

  Future<void> _showLocationPickerModal() async {
    if (!mounted) return;

    final modalMapController = MapController();
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is permanently denied.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      await Geolocator.openAppSettings();
    }

    final hasPermission =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location Services are off.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      await Geolocator.openLocationSettings();
    }

    if (!mounted) return;
    setState(() {
      _permissionGranted = hasPermission;
    });

    final cachedLocation = await LocationService.getCachedUserLocation();
    if (cachedLocation != null) {
      await _updateDraftLocation(
        cachedLocation.latitude,
        cachedLocation.longitude,
      );
    } else if (hasPermission && serviceEnabled) {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        await LocationService.cacheUserLocation(location);
        await LocationService.grantLocationPermission(widget.userId);
        await _updateDraftLocation(location.latitude, location.longitude);
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final currentLocation =
                    _draftLocation ??
                    LocationCoords(latitude: 27.7172, longitude: 85.324);

                final markers = <Marker>[
                  Marker(
                    point: LatLng(
                      currentLocation.latitude,
                      currentLocation.longitude,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 36,
                    ),
                  ),
                ];

                return Column(
                  children: [
                    // Header
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          onChanged: (value) =>
                                              setModalState(() {
                                                _searchQuery = value;
                                              }),
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search for an address...',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: _isSearching
                                            ? null
                                            : () async {
                                                await _searchAddress(
                                                  setModalState,
                                                  modalMapController,
                                                );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2563EB,
                                          ),
                                          disabledBackgroundColor: Colors.grey,
                                        ),
                                        child: _isSearching
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Text('Search'),
                                      ),
                                    ],
                                  ),
                                  if (_searchError.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _searchError,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_permissionGranted &&
                                _draftLocation != null &&
                                _draftAddress.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  border: Border.all(color: Colors.green[200]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green[600],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current location tracked',
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _draftAddress,
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: FlutterMap(
                                    mapController: modalMapController,
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                        currentLocation.latitude,
                                        currentLocation.longitude,
                                      ),
                                      initialZoom: 15,
                                      onTap: (_, latLng) =>
                                          _onMapTapped(latLng, setModalState),
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.example.room_rental',
                                      ),
                                      MarkerLayer(markers: markers),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (_draftLocation != null)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Selected Location:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _draftAddress.isNotEmpty
                                          ? _draftAddress
                                          : 'Searching address...',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),

                            const Text(
                              'Tap on the map or drag the marker to update the location',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                        color: Colors.grey[50],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _draftLocation == null
                                ? null
                                : _confirmLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              disabledBackgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Confirm Location'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _confirmedAddress.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showLocationPickerModal,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: hasLocation
                    ? const Color(0xFF2563EB)
                    : Colors.grey[300]!,
                width: hasLocation ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: hasLocation ? const Color(0xFFEFF6FF) : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: hasLocation
                      ? const Color(0xFF2563EB)
                      : Colors.grey[400],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation
                            ? _confirmedAddress
                            : 'No location selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: hasLocation
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: hasLocation
                              ? const Color(0xFF1F2937)
                              : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasLocation) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tap to change location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  hasLocation
                      ? Icons.edit_location_alt
                      : Icons.add_location_alt,
                  color: const Color(0xFF2563EB),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
