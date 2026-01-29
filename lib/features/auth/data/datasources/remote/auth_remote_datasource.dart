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
  Future<AuthApiModel> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
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
      
      // Extract userId from raw data since API uses "_id"
      final userId = data['_id'] as String?;
      
      print('DEBUG userId from API: $userId');
        
      //Save user session with correct userId
      await _userSessionService.saveUserSession(
        userId: userId ?? '',
        fullName: user.fullName,
        email: user.email,
        role: user.role,
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
}
