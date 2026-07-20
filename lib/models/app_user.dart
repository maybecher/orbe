/// Roles that determine what a user can do inside Orbe.
enum UserRole {
  user,
  technician,
  admin;

  String get label => switch (this) {
        UserRole.user => 'Usuário',
        UserRole.technician => 'Técnico',
        UserRole.admin => 'Administrador',
      };
}

/// Immutable representation of an authenticated user.
///
/// This is the domain model shared across the app. It is intentionally
/// storage-agnostic so the same object works whether it comes from the
/// mock repository or, later, from Firebase.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.user,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  AppUser copyWith({String? name, String? email, UserRole? role}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppUser && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}
