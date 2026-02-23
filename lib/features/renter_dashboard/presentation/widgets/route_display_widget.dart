import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage/location_service.dart';

class RouteDisplayWidget extends ConsumerStatefulWidget {
  final LocationCoords roomLocation;
  final String roomAddress;
  final String? userId;
  final VoidCallback? onShowNavigation;

  const RouteDisplayWidget({
    Key? key,
    required this.roomLocation,
    required this.roomAddress,
    this.userId,
    this.onShowNavigation,
  }) : super(key: key);

  @override
  ConsumerState<RouteDisplayWidget> createState() => _RouteDisplayWidgetState();
}

class _RouteDisplayWidgetState extends ConsumerState<RouteDisplayWidget> {
  LocationCoords? _userLocation;
  double? _distance;
  String? _travelTime;
  bool _permissionGranted = false;
  bool _loading = false;
  bool _showRouteDetails = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadLocation();
  }

  Future<void> _checkPermissionAndLoadLocation() async {
    final hasPermission =
        await LocationService.checkLocationPermission(widget.userId);
    setState(() {
      _permissionGranted = hasPermission;
    });

    if (hasPermission) {
      final cached = await LocationService.getCachedUserLocation();
      if (cached != null) {
        _calculateRoute(cached);
      }
    }
  }

  void _calculateRoute(LocationCoords userLoc) {
    final distance = LocationService.calculateDistance(
      userLoc.latitude,
      userLoc.longitude,
      widget.roomLocation.latitude,
      widget.roomLocation.longitude,
    );

    final travelTime = LocationService.estimateTravelTime(distance);

    setState(() {
      _userLocation = userLoc;
      _distance = distance;
      _travelTime = travelTime;
    });
  }

  Future<void> _requestLocation() async {
    setState(() => _loading = true);

    try {
      final permission = await LocationService.requestLocationPermission();

      if (permission == LocationPermissionStatus.granted) {
        final location = await LocationService.getCurrentLocation();
        if (location != null) {
          await LocationService.cacheUserLocation(location);
          await LocationService.grantLocationPermission(widget.userId);

          setState(() => _permissionGranted = true);
          _calculateRoute(location);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location accessed successfully')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionGranted) {
      return InkWell(
        onTap: _loading ? null : _requestLocation,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
            const SizedBox(width: 8),
            Text(
              _loading ? 'Accessing location...' : 'Show distance & route',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_userLocation == null || _distance == null) {
      return Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            'Location data unavailable',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showRouteDetails = !_showRouteDetails;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6),
                Text(
                  '${LocationService.formatDistance(_distance!)} away',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 4),
                Text(
                  _travelTime ?? '--',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                Icon(
                  _showRouteDetails
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ),

        if (_showRouteDetails) ...[
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEFF6FF), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.navigation,
                                  size: 16,
                                  color: Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  LocationService.formatDistance(_distance!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Distance from you',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFBEB), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _travelTime ?? '--',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Travel time',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onShowNavigation,
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text(
                      'View Route on Map',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
