import '../models/app_user.dart';

/// Error thrown by an [AuthRepository] with a user-facing [message].
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Contract for authentication data sources.
///
/// The UI and providers depend only on this abstraction, so swapping the
/// [MockAuthRepository] for a Firebase implementation later requires no
/// changes above this layer.
abstract interface class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  /// All registered accounts. Used by the admin "Gerenciar usuários" screen.
  Future<List<AppUser>> fetchAllUsers();

  /// Permanently removes an account. Used by the admin "Gerenciar usuários"
  /// screen.
  Future<void> deleteAccount(String userId);
}

/// In-memory implementation used during development and for the portfolio
/// demo. Simulates network latency and basic validation without any backend.
class MockAuthRepository implements AuthRepository {
  final Map<String, _Account> _accounts = {
    'demo@orbe.com': const _Account(
      user: AppUser(
        id: '1',
        name: 'Demo Orbe',
        email: 'demo@orbe.com',
        role: UserRole.user,
      ),
      password: '123456',
    ),
    'admin@orbe.com': const _Account(
      user: AppUser(
        id: '2',
        name: 'Admin Orbe',
        email: 'admin@orbe.com',
        role: UserRole.admin,
      ),
      password: '123456',
    ),
  };

  static const Duration _latency = Duration(milliseconds: 800);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('E-mail ou senha inválidos.');
    }
    return account.user;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('Já existe uma conta com este e-mail.');
    }
    final user = AppUser(
      id: '${_accounts.length + 1}',
      name: name.trim(),
      email: key,
    );
    _accounts[key] = _Account(user: user, password: password);
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(_latency);
    if (!_accounts.containsKey(email.trim().toLowerCase())) {
      throw const AuthException('Nenhuma conta encontrada com este e-mail.');
    }
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<AppUser>> fetchAllUsers() async {
    await Future<void>.delayed(_latency);
    return _accounts.values.map((a) => a.user).toList();
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await Future<void>.delayed(_latency);
    _accounts.removeWhere((_, account) => account.user.id == userId);
  }
}

class _Account {
  const _Account({required this.user, required this.password});
  final AppUser user;
  final String password;
}
