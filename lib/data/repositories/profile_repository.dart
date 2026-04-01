import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_profile.dart';

class ProfileRepository {
  static const String _key = 'user_profile';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(profile.toJson());
    await prefs.setString(_key, json);
  }

  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfile = prefs.getString(_key);

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

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
