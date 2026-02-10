// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) => AuthApiModel(
      userId: json['_id'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      role: json['role'] as String,
      profilePicture: json['profilePicture'] as String?,
      confirmPassword: json['confirmPassword'] as String?,
    );

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) {
  final val = <String, dynamic>{
    '_id': instance.userId,
    'fullName': instance.fullName,
    'email': instance.email,
    'password': instance.password,
    'role': instance.role,
    'profilePicture': instance.profilePicture,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('confirmPassword', instance.confirmPassword);
  return val;
}
