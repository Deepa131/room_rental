import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class LocationCoords {
  final double latitude;
  final double longitude;
  final String? address;

  LocationCoords({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory LocationCoords.fromJson(Map<String, dynamic> json) {
    return LocationCoords(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      address: json['address'],
    );
  }
}

class LocationService {
  static const String _locationPermissionKey = 'location_permission_granted';
  static const String _userLocationKey = 'user_current_location';
  static const String _roomLocationPrefix = 'room_location_';

  static Future<bool> checkLocationPermission(String? userId) async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<void> grantLocationPermission(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = userId != null
        ? '${_locationPermissionKey}_$userId'
        : _locationPermissionKey;
    await prefs.setBool(key, true);
  }

  static Future<LocationPermissionStatus> requestLocationPermission() async {
    // First check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.denied;
    }

    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();
    
    // If permission is denied, request it
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Handle all permission states
    switch (permission) {
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  static Future<LocationCoords?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationCoords(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> cacheUserLocation(LocationCoords location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userLocationKey,
      jsonEncode(location.toJson()),
    );
  }

  static Future<LocationCoords?> getCachedUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_userLocationKey);
    if (cached != null) {
      return LocationCoords.fromJson(jsonDecode(cached));
    }
    return null;
  }

  static Future<void> cacheRoomLocation(
    String roomId,
    LocationCoords location,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_roomLocationPrefix$roomId',
      jsonEncode(location.toJson()),
    );
  }

  static Future<LocationCoords?> getCachedRoomLocation(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_roomLocationPrefix$roomId');
    if (cached != null) {
      return LocationCoords.fromJson(jsonDecode(cached));
    }
    return null;
  }

  /// Calculate distance between two coordinates in kilometers using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);
    final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
        cos(lat2 * pi / 180) *
        sin(dLon / 2) *
        sin(dLon / 2);
    final c = 2 * asin(sqrt(a));
    return R * c;
  }

  /// Format distance for display
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)}m';
    }
    return '${km.toStringAsFixed(1)}km';
  }

  /// Estimate travel time (average speed: 40km/h)
  static String estimateTravelTime(double distanceKm) {
    const avgSpeed = 40; // km/h
    final minutes = ((distanceKm / avgSpeed) * 60).toInt();

    if (minutes < 1) return '1min';
    if (minutes < 60) return '${minutes}min';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
  }

  /// Get Google Maps URL for routing
  static String getGoogleMapsUrl(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return 'https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&route=$startLat%2C$startLon%3B$endLat%2C$endLon';
  }

  /// Reverse geocode coordinates to a readable address using Nominatim
  static Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': 'en',
            'User-Agent': 'room_rental_flutter',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['display_name'] != null) {
        return data['display_name'] as String;
      }
      return 'Address unavailable';
    } catch (_) {
      return 'Address unavailable';
    }
  }

  /// Geocode address to coordinates using Nominatim
  static Future<LocationCoords?> geocodeAddress(String address) async {
    try {
      final dio = Dio();
      
      // Try with Nepal context first
      var response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': '$address, Nepal',
          'format': 'jsonv2',
          'limit': 5,
          'addressdetails': 1,
          'countrycodes': 'np',
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Accept-Language': 'en',
            'User-Agent': 'room_rental_flutter',
          },
        ),
      );

      var data = response.data;
      
      // If no results with Nepal context, try without it
      if (data is List && data.isEmpty) {
        response = await dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': address,
            'format': 'jsonv2',
            'limit': 5,
            'addressdetails': 1,
          },
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'en',
              'User-Agent': 'room_rental_flutter',
            },
          ),
        );
        data = response.data;
      }

      if (response.statusCode != 200) {
        return null;
      }

      if (data is List && data.isNotEmpty) {
        final result = data.first as Map<String, dynamic>;
        
        try {
          final lat = double.parse(result['lat'].toString());
          final lon = double.parse(result['lon'].toString());
          final displayName = result['display_name']?.toString() ?? address;

          return LocationCoords(
            latitude: lat,
            longitude: lon,
            address: displayName,
          );
        } catch (e) {
          return null;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

enum LocationPermissionStatus { granted, denied, permanentlyDenied }
