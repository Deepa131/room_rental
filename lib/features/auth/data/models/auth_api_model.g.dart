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
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('_id', instance.userId);
  val['fullName'] = instance.fullName;
  val['email'] = instance.email;
  val['password'] = instance.password;
  val['role'] = instance.role;
  val['profilePicture'] = instance.profilePicture;
  writeNotNull('confirmPassword', instance.confirmPassword);
  return val;
}
