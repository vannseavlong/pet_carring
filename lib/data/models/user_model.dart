import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.email,
    required super.fullName,
    required super.role,
    super.picture,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        userId: j['user_id'] as String,
        email: j['email'] as String,
        fullName: j['full_name'] as String,
        role: j['role'] as String,
        picture: j['picture'] as String?,
      );
}
