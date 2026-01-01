import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String email;
  final String password;
  final String role;

  const AuthEntity ({
    this.userId, 
    required this.fullName, 
    required this.email, 
    required this.password, 
    required this.role
  });
  
  @override
  List<Object?> get props => [
    userId, fullName, email, password, role
  ];
}