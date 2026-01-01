import 'package:hive/hive.dart';
import 'package:room_rental/core/constants/auth_hive_constants.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: AuthHiveConstants.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String role;

  AuthHiveModel ({
    String? userId, 
    required this.fullName, 
    required this.email, 
    required this.password, 
    required this.role,
  }) : userId = userId ?? const Uuid().v4();

  //from entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      fullName: entity.fullName, 
      email: entity.email, 
      password: entity.password,
      role: entity.role
    );
  }

  //to entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      fullName: fullName, 
      email: email, 
      password: password, 
      role: role
    );
  }
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}