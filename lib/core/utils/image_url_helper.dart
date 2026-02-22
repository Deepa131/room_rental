import 'package:room_rental/core/api/api_endpoints.dart';

class ImageUrlHelper {
  ImageUrlHelper._();

  /// Converts a relative image path to a full URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Remove leading slashes and construct full URL
    final cleanPath = imagePath.replaceFirst(RegExp(r'^/+'), '');

    // Extract base URL without the /api/ part
    final baseUrl = ApiEndpoints.baseUrl.replaceFirst(RegExp(r'/api/$'), '');

    // If path already contains 'public/', don't add it again
    if (cleanPath.startsWith('public/')) {
      return '$baseUrl/$cleanPath';
    }

    // Preserve explicit media folders, otherwise default to room_images
    if (cleanPath.startsWith('room_images/') ||
        cleanPath.startsWith('room_videos/') ||
        cleanPath.startsWith('profile_pictures/')) {
      return '$baseUrl/public/$cleanPath';
    }

    // Detect video files by extension and use room_videos folder
    if (cleanPath.toLowerCase().endsWith('.mp4') ||
        cleanPath.toLowerCase().endsWith('.mov') ||
        cleanPath.toLowerCase().endsWith('.avi') ||
        cleanPath.toLowerCase().endsWith('.webm')) {
      return '$baseUrl/public/room_videos/$cleanPath';
    }

    return '$baseUrl/public/room_images/$cleanPath';
  }

  // Converts a profile picture path to a full URL
  static String getProfilePictureUrl(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return '';
    }

    // If it's already a full URL, return as is
    if (profilePicture.startsWith('http://') || profilePicture.startsWith('https://')) {
      return profilePicture;
    }

    // Remove leading slashes
    final cleanPath = profilePicture.replaceFirst(RegExp(r'^/+'), '');

    // Extract base URL without the /api/ part
    final baseUrl = ApiEndpoints.baseUrl.replaceFirst(RegExp(r'/api/$'), '');

    // If path already contains 'public/', don't add it again
    if (cleanPath.startsWith('public/')) {
      return '$baseUrl/$cleanPath';
    }

    // Construct the public URL
    return '$baseUrl/public/$cleanPath';
  }
}
