import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/api/api_client.dart';
import 'package:room_rental/core/api/api_endpoints.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/core/services/storage/token_service.dart';
import 'package:room_rental/features/auth/data/datasources/auth_datasource.dart';
import 'package:room_rental/features/auth/data/models/auth_api_model.dart';

//provider
final authRemoteProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    final response = await _apiClient.get(
      ApiEndpoints.userById(authId),
    );
    
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );
      
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);
      final userId = data['_id'] as String?;
        
      //Save user session with correct userId AND profile picture
      await _userSessionService.saveUserSession(
        userId: userId ?? '',
        fullName: user.fullName,
        email: user.email,
        role: user.role,
        profileImage: user.profilePicture,
      );
      final token = response.data['token'];
      await _tokenService.saveToken(token);
      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }

  @override
  Future<bool> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );

    return response.data['success'] == true;
  }

  @override
  Future<bool> resetPassword(String token, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword(token),
      data: {'password': password},
    );

    return response.data['success'] == true;
  }

  @override
  Future<AuthApiModel> updateProfile(String id, AuthApiModel user, {File? imageFile}) async {
    if (imageFile != null) {
      // Send as multipart/form-data if image is being uploaded
      final formData = FormData.fromMap({
        'fullName': user.fullName,
        'email': user.email,
        'role': user.role,
        'profilePicture': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      print('FormData created with fields: fullName, email, role, profilePicture (file)');
      print('Image file path: ${imageFile.path}');
      
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile(id),
        data: formData,
      );

      print('Response data: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final updatedUser = AuthApiModel.fromJson(data);
        
        print('Updated profile picture path: ${updatedUser.profilePicture}');
        
        // Update user session WITH profile picture
        await _userSessionService.saveUserSession(
          userId: id,
          fullName: updatedUser.fullName,
          email: updatedUser.email,
          role: updatedUser.role,
          profileImage: updatedUser.profilePicture,
        );
        
        return updatedUser;
      }
    } else {
      // Send as JSON if no image
      final jsonData = user.toUpdateJson();
      
      // Handle picture removal - send "null" string if profilePicture is empty (user removed it)
      if (user.profilePicture == '') {
        jsonData['profilePicture'] = 'null';
      }
      
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile(id),
        data: jsonData,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final updatedUser = AuthApiModel.fromJson(data);
        
        // Update user session WITH profile picture
        await _userSessionService.saveUserSession(
          userId: id,
          fullName: updatedUser.fullName,
          email: updatedUser.email,
          role: updatedUser.role,
          profileImage: updatedUser.profilePicture,
        );
        
        return updatedUser;
      }
    }

    return user;
  }

  @override
  Future<String> updateProfilePicture(File image) async {
    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    final response = await _apiClient.put(
      ApiEndpoints.updateProfilePicture,
      data: formData,
    );

    if (response.data['success'] == true) {
      return response.data['data']['profilePicture'] as String;
    }

    throw Exception('Failed to upload profile picture');
  }
}
