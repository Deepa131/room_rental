import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/api/api_endpoints.dart';
import 'package:room_rental/core/utils/image_url_helper.dart';

void main() {
  final baseUrl = ApiEndpoints.baseUrl.replaceFirst(RegExp(r'/api/$'), '');

  group('ImageUrlHelper.getImageUrl', () {
    test('returns empty for null', () {
      expect(ImageUrlHelper.getImageUrl(null), '');
    });

    test('returns empty for empty string', () {
      expect(ImageUrlHelper.getImageUrl(''), '');
    });

    test('returns same for http URL', () {
      const url = 'http://example.com/image.jpg';
      expect(ImageUrlHelper.getImageUrl(url), url);
    });

    test('returns same for https URL', () {
      const url = 'https://example.com/image.jpg';
      expect(ImageUrlHelper.getImageUrl(url), url);
    });

    test('keeps public path', () {
      const path = 'public/room_images/photo.jpg';
      expect(ImageUrlHelper.getImageUrl(path), '$baseUrl/$path');
    });

    test('keeps room_images path', () {
      const path = 'room_images/photo.jpg';
      expect(
        ImageUrlHelper.getImageUrl(path),
        '$baseUrl/public/$path',
      );
    });

    test('keeps room_videos path', () {
      const path = 'room_videos/clip.mp4';
      expect(
        ImageUrlHelper.getImageUrl(path),
        '$baseUrl/public/$path',
      );
    });

    test('keeps profile_pictures path', () {
      const path = 'profile_pictures/user.png';
      expect(
        ImageUrlHelper.getImageUrl(path),
        '$baseUrl/public/$path',
      );
    });

    test('routes video extensions to room_videos', () {
      const path = 'sample.mov';
      expect(
        ImageUrlHelper.getImageUrl(path),
        '$baseUrl/public/room_videos/$path',
      );
    });

    test('defaults to room_images for other files', () {
      const path = 'cover.jpg';
      expect(
        ImageUrlHelper.getImageUrl(path),
        '$baseUrl/public/room_images/$path',
      );
    });
  });

  group('ImageUrlHelper.getProfilePictureUrl', () {
    test('returns empty for null', () {
      expect(ImageUrlHelper.getProfilePictureUrl(null), '');
    });

    test('returns empty for empty string', () {
      expect(ImageUrlHelper.getProfilePictureUrl(''), '');
    });

    test('returns same for http URL', () {
      const url = 'http://example.com/avatar.png';
      expect(ImageUrlHelper.getProfilePictureUrl(url), url);
    });

    test('keeps public path', () {
      const path = 'public/profile_pictures/avatar.png';
      expect(ImageUrlHelper.getProfilePictureUrl(path), '$baseUrl/$path');
    });

    test('prefixes base URL for relative path', () {
      const path = 'profile_pictures/avatar.png';
      expect(
        ImageUrlHelper.getProfilePictureUrl(path),
        '$baseUrl/public/$path',
      );
    });
  });
}
