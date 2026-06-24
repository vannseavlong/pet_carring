import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final String? picture;

  const User({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    this.picture,
  });

  @override
  List<Object?> get props => [userId, email, fullName, role, picture];
}
