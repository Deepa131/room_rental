import 'package:room_rental/core/api/api_endpoints.dart';

class ImageUrlHelper {
  ImageUrlHelper._();

  /// Converts a relative image path to a full URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return '';
    }

    // Normalize slashes because backend paths may contain Windows separators.
    final normalizedPath = imagePath.trim().replaceAll('\\', '/');

    // If it's already a full URL, return as is
    if (normalizedPath.startsWith('http://') || normalizedPath.startsWith('https://')) {
      return normalizedPath;
    }

    // Remove leading slashes and construct full URL
    var cleanPath = normalizedPath.replaceFirst(RegExp(r'^/+'), '');

    // If a known media folder appears later in the path, keep only from that segment.
    for (final folder in ['room_images/', 'room_videos/', 'profile_pictures/']) {
      final folderIndex = cleanPath.indexOf(folder);
      if (folderIndex > 0) {
        cleanPath = cleanPath.substring(folderIndex);
        break;
      }
    }

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
    if (profilePicture == null || profilePicture.trim().isEmpty) {
      return '';
    }

    final normalizedPath = profilePicture.trim().replaceAll('\\', '/');

    // If it's already a full URL, return as is
    if (normalizedPath.startsWith('http://') || normalizedPath.startsWith('https://')) {
      return normalizedPath;
    }

    // Remove leading slashes
    final cleanPath = normalizedPath.replaceFirst(RegExp(r'^/+'), '');

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
