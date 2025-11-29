enum UserRole {
  admin,
  warden,
  messManager,
  staff,
  student;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.warden:
        return 'Warden';
      case UserRole.messManager:
        return 'Mess Manager';
      case UserRole.staff:
        return 'Staff';
      case UserRole.student:
        return 'Student';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'warden':
        return UserRole.warden;
      case 'messmanager':
      case 'mess_manager':
        return UserRole.messManager;
      case 'staff':
        return UserRole.staff;
      case 'student':
        return UserRole.student;
      default:
        throw Exception('Invalid user role: $role');
    }
  }
}
