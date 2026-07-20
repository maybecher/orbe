import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/external_profile.dart';

/// Contract for sourcing and persisting external (randomuser.me) profiles
/// used to back common-user accounts. The UI and providers depend only on
/// this abstraction.
abstract interface class ExternalProfileRepository {
  /// Fetches a fresh random person, used by the "Gerar usuário" action on
  /// the register screen. Does not persist anything by itself.
  Future<ExternalProfile> fetchRandomProfile();

  /// Permanently links [profile] to [userId], e.g. right after that user's
  /// account is created.
  void assignProfile(String userId, ExternalProfile profile);

  /// The profile previously assigned to [userId], if any.
  ExternalProfile? profileForUser(String userId);
}

/// In-memory implementation: profiles are fetched from randomuser.me and
/// then held in a simple map for the lifetime of the app session.
class RandomUserProfileRepository implements ExternalProfileRepository {
  RandomUserProfileRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, ExternalProfile> _assigned = {};

  static final Uri _endpoint = Uri.parse('https://randomuser.me/api/');

  @override
  Future<ExternalProfile> fetchRandomProfile() async {
    final response = await _client.get(_endpoint);
    if (response.statusCode != 200) {
      throw Exception('Falha ao buscar usuário (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    return ExternalProfile.fromRandomUserJson(
      results.first as Map<String, dynamic>,
    );
  }

  @override
  void assignProfile(String userId, ExternalProfile profile) {
    _assigned[userId] = profile;
  }

  @override
  ExternalProfile? profileForUser(String userId) => _assigned[userId];
}
