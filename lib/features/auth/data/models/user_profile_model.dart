import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../../../core/constants/firestore_constants.dart';

/// Firestore document model for user profile (collection: users).
/// Maps to/from [UserEntity] and handles [Timestamp] for JSON.
class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      FirestoreConstants.id: id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      if (role != null) 'role': role!.value,
      FirestoreConstants.createdAt: createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      FirestoreConstants.updatedAt: updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  static UserProfileModel fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json[FirestoreConstants.id] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] != null ? UserRole.fromString(json['role'] as String) : null,
      createdAt: _parseTimestamp(json[FirestoreConstants.createdAt]),
      updatedAt: _parseTimestamp(json[FirestoreConstants.updatedAt]),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        role: role ?? UserRole.student,
      );

  static UserProfileModel fromEntity(UserEntity entity, {DateTime? createdAt, DateTime? updatedAt}) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      role: entity.role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
