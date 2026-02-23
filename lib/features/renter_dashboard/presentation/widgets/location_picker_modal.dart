import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/storage/location_service.dart';

class LocationPickerModal extends StatefulWidget {
  final Function(LocationCoords, String) onLocationSelect;
  final LocationCoords? defaultLocation;
  final String? userId;

  const LocationPickerModal({
    Key? key,
    required this.onLocationSelect,
    this.defaultLocation,
    this.userId,
  }) : super(key: key);

  @override
  State<LocationPickerModal> createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  final MapController _mapController = MapController();
  LocationCoords? _selectedLocation;
  String _selectedAddress = '';
  bool _isSearching = false;
  String _searchQuery = '';
  String _searchError = '';
  bool _permissionGranted = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.defaultLocation;
    _selectedAddress = widget.defaultLocation?.address ?? '';
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    if (_selectedLocation != null) {
      // Already have a location, no need to request current location
      return;
    }

    setState(() => _isLoadingLocation = true);

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission permanently denied. You can still pick manually.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _isLoadingLocation = false);
      return;
    }

    final hasPermission =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    setState(() => _permissionGranted = hasPermission);

    if (hasPermission) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are off. You can still pick manually.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Try to get cached location first
      final cachedLocation = await LocationService.getCachedUserLocation();
      if (cachedLocation != null) {
        await _updateSelectedLocation(
          cachedLocation.latitude,
          cachedLocation.longitude,
        );
      } else if (hasPermission && serviceEnabled) {
        // Get current location
        final location = await LocationService.getCurrentLocation();
        if (location != null) {
          await LocationService.cacheUserLocation(location);
          await LocationService.grantLocationPermission(widget.userId);
          await _updateSelectedLocation(location.latitude, location.longitude);
        }
      }
    }

    setState(() => _isLoadingLocation = false);
  }

  Future<void> _updateSelectedLocation(double latitude, double longitude) async {
    final address = await LocationService.reverseGeocode(latitude, longitude);
    if (!mounted) return;

    setState(() {
      _selectedLocation = LocationCoords(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _selectedAddress = address;
    });

    // Move map to the new location
    _mapController.move(LatLng(latitude, longitude), 15);
  }

  Future<void> _searchAddress() async {
    if (_searchQuery.trim().isEmpty) {
      setState(() => _searchError = 'Enter a location to search');
      return;
    }

    setState(() {
      _searchError = '';
      _isSearching = true;
    });

    try {
      final result = await LocationService.geocodeAddress(_searchQuery.trim());
      if (!mounted) return;

      if (result == null) {
        setState(() {
          _searchError = 'No results found. Try "Kathmandu", "Patan", or "Pokhara"';
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _selectedLocation = result;
        _selectedAddress = result.address ?? 'Selected location';
        _searchError = '';
        _isSearching = false;
      });

      // Move map to search result
      _mapController.move(LatLng(result.latitude, result.longitude), 15);
    } catch (e) {
      setState(() {
        _searchError = 'Search error: $e';
        _isSearching = false;
      });
    }
  }

  void _onMapTapped(LatLng position) {
    _updateSelectedLocation(position.latitude, position.longitude);
  }

  void _confirmLocation() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onLocationSelect(_selectedLocation!, _selectedAddress);
    Navigator.pop(context);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location confirmed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = _selectedLocation ??
        LocationCoords(latitude: 27.7172, longitude: 85.324); // Default to Kathmandu

    final markers = _selectedLocation != null
        ? <Marker>[
            Marker(
              point: LatLng(
                _selectedLocation!.latitude,
                _selectedLocation!.longitude,
              ),
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 36,
              ),
            ),
          ]
        : <Marker>[];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
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
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Select Location',
                        style: TextStyle(
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) => setState(() => _searchQuery = value),
                                  decoration: InputDecoration(
                                    hintText: 'Search for an address...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _isSearching ? null : _searchAddress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  disabledBackgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isSearching
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
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
                      const SizedBox(height: 16),

                      // Permission/Location indicator
                      if (_isLoadingLocation)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            border: Border.all(color: Colors.blue[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue[600]!,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Getting your location...',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_permissionGranted && _selectedAddress.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            border: Border.all(color: Colors.green[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.green[600], size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      _selectedAddress,
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
                      const SizedBox(height: 16),

                      // Map
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(
                                currentLocation.latitude,
                                currentLocation.longitude,
                              ),
                              initialZoom: 15,
                              onTap: (_, latLng) => _onMapTapped(latLng),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.room_rental',
                              ),
                              MarkerLayer(markers: markers),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selected location display
                      if (_selectedLocation != null)
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
                                _selectedAddress.isNotEmpty
                                    ? _selectedAddress
                                    : 'Searching address...',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Instructions
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
            ),

            // Footer with buttons
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
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
                    onPressed: _selectedLocation == null ? null : _confirmLocation,
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
  }
}
