import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/storage/location_service.dart';
import 'dart:async';

class NavigationContainer extends StatefulWidget {
  final LocationCoords userLocation;
  final LocationCoords roomLocation;
  final String roomAddress;

  const NavigationContainer({
    Key? key,
    required this.userLocation,
    required this.roomLocation,
    required this.roomAddress,
  }) : super(key: key);

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  bool _isNavigating = false;
  late LatLng _currentLocation;
  bool _hasArrived = false;
  bool _isExpanded = true;
  StreamSubscription<Position>? _positionStreamSubscription;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _currentLocation = LatLng(
      widget.userLocation.latitude,
      widget.userLocation.longitude,
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  double _calculateDistance() {
    return LocationService.calculateDistance(
      _currentLocation.latitude,
      _currentLocation.longitude,
      widget.roomLocation.latitude,
      widget.roomLocation.longitude,
    );
  }

  void _startNavigation() async {
    setState(() {
      _isNavigating = true;
      _hasArrived = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚀 Navigation started! Your location will update in real-time.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Start listening to position updates
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Center map on user's current position
      _mapController.move(_currentLocation, _mapController.camera.zoom);

      // Check if arrived (within 50 meters)
      final distance = _calculateDistance();
      if (distance < 0.05 && !_hasArrived) {
        setState(() {
          _hasArrived = true;
          _isNavigating = false;
        });
        _positionStreamSubscription?.cancel();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 You have arrived at your destination!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _stopNavigation() {
    _positionStreamSubscription?.cancel();
    setState(() {
      _isNavigating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation stopped'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomPos = LatLng(
      widget.roomLocation.latitude,
      widget.roomLocation.longitude,
    );

    // Calculate center and bounds
    final centerLat = (_currentLocation.latitude + roomPos.latitude) / 2;
    final centerLng = (_currentLocation.longitude + roomPos.longitude) / 2;
    final center = LatLng(centerLat, centerLng);

    final distance = _calculateDistance();
    final travelTime = LocationService.estimateTravelTime(distance);

    return Column(
      children: [
        // Navigation Header
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.navigation, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Navigate to Room',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.near_me, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          LocationService.formatDistance(distance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'away',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.schedule, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          travelTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_hasArrived) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Arrived!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          // Map Container
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SizedBox(
                  height: 400,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 13.0,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.room_rental',
                      ),
                      // Route line
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [_currentLocation, roomPos],
                            strokeWidth: 4.0,
                            color: const Color(0xFF3B82F6),
                            borderColor: Colors.white,
                            borderStrokeWidth: 1.0,
                          ),
                        ],
                      ),
                      // Markers
                      MarkerLayer(
                        markers: [
                          // User location marker (blue)
                          Marker(
                            point: _currentLocation,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.circle,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                          // Room location marker (red)
                          Marker(
                            point: roomPos,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Controls Footer
                Container(
                  color: Colors.grey[50],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Destination Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFDC2626),
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.roomAddress,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Navigation Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _hasArrived
                              ? null
                              : (_isNavigating ? _stopNavigation : _startNavigation),
                          icon: Icon(
                            _isNavigating ? Icons.stop : Icons.play_arrow,
                            size: 18,
                          ),
                          label: Text(
                            _isNavigating ? 'Stop Navigation' : 'Start Navigation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isNavigating
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                            disabledBackgroundColor: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
