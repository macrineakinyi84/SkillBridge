/// Backend role; must match API (student | employer | admin).
enum UserRole {
  student,
  employer,
  admin;

  /// Parse from API/JWT string. Defaults to [student] if invalid or null.
  static UserRole fromString(String? value) {
    if (value == null || value.isEmpty) return UserRole.student;
    switch (value.toLowerCase()) {
      case 'employer':
        return UserRole.employer;
      case 'admin':
        return UserRole.admin;
      case 'student':
      case 'user': // legacy
      default:
        return UserRole.student;
    }
  }

  String get value => name;
}
