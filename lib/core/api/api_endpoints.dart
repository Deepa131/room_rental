class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String users = '/users';
  static const String userLogin = '/users/login';
  static const String userRegister = '/users/register';
  static String userById(String id) => '/users/$id';
  static String userPhoto(String id) => 'users/$id/photo';
}