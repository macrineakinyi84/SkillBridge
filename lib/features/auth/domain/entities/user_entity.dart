import 'package:equatable/equatable.dart';

import 'user_role.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.student,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;

  /// Build from backend JWT claims or login/verify-otp response user object.
  /// Role is parsed and persisted via the JWT stored in secure storage.
  static UserEntity fromBackendClaims(Map<String, dynamic> claims) {
    return UserEntity(
      id: (claims['userId'] ?? claims['sub'] ?? '').toString(),
      email: (claims['email'] ?? '').toString(),
      displayName: claims['displayName'] as String?,
      photoUrl: claims['photoUrl'] as String?,
      role: UserRole.fromString(claims['role'] as String?),
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, role];
}
