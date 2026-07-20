import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/external_profile.dart';
import '../services/auth_repository.dart';
import 'external_profile_provider.dart';

/// Provides the active [AuthRepository]. Swap the implementation here
/// (e.g. to Firebase) without touching the UI or the controller.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

/// Holds the authentication state as an [AsyncValue] wrapping the current
/// user (`null` when signed out). Screens watch this to react to loading,
/// errors and the logged-in user.
class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async => null;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.signIn(email: email, password: password),
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    ExternalProfile? externalProfile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user =
          await _repository.signUp(name: name, email: email, password: password);
      if (externalProfile != null) {
        ref
            .read(externalProfileRepositoryProvider)
            .assignProfile(user.id, externalProfile);
      }
      return user;
    });
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.sendPasswordReset(email);
      return null;
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);
