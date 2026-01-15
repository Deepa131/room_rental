import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? userId;
  final String fullName;
  final String email;
  final String? password;
  final String role;
  final String? profilePicture;

  AuthApiModel({
    this.userId, 
    required this.fullName, 
    required this.email, 
    this.password, 
    required this.role, 
    this.profilePicture
  });

  //toJSON
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "password": password,
      "role": role,
      "profilePicture": profilePicture,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      userId: json['_id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      role: role,
      profilePicture: profilePicture, 
      password: ''
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      // id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      role: entity.role,
      profilePicture: entity.profilePicture,
      password: entity.password,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
