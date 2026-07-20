import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/external_profile.dart';
import '../services/external_profile_repository.dart';
import 'auth_provider.dart';

/// Provides the active [ExternalProfileRepository]. Swap the implementation
/// here without touching the UI.
final externalProfileRepositoryProvider = Provider<ExternalProfileRepository>((ref) {
  return RandomUserProfileRepository();
});

/// The external profile permanently assigned to the current account, if
/// any. Common-user accounts created via the "Gerar usuário" action on
/// sign-up have one; accounts created any other way don't. Purely a
/// synchronous lookup — never refetches on its own.
final externalProfileProvider = Provider<ExternalProfile?>((ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return null;
  return ref.watch(externalProfileRepositoryProvider).profileForUser(user.id);
});
