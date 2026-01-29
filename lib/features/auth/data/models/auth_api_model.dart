import 'package:json_annotation/json_annotation.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  @JsonKey(name: '_id')
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
  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) => _$AuthApiModelFromJson(json);

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
