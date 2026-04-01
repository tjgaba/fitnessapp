import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_profile.dart';

class ProfileRepository {
  static const String _guestKey = 'user_profile_guest';

  Future<void> saveProfile(String userId, UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(profile.toJson());
    await prefs.setString(_storageKey(userId), json);
  }

  Future<UserProfile> loadProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfile = prefs.getString(_storageKey(userId));

    if (rawProfile == null || rawProfile.isEmpty) {
      return const UserProfile.defaults();
    }

    try {
      final decoded = jsonDecode(rawProfile);
      if (decoded is! Map) {
        return const UserProfile.defaults();
      }

      return UserProfile.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return const UserProfile.defaults();
    }
  }

  Future<void> clearProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(userId));
  }

  String _storageKey(String userId) {
    if (userId.trim().isEmpty) {
      return _guestKey;
    }
    return 'user_profile_$userId';
  }
}
