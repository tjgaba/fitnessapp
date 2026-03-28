import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise.dart';

class RoutineRepository {
  static const String _key = 'exercise_routine';

  Future<void> saveRoutine(List<Exercise> routine) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(
      routine.map((exercise) => exercise.toJson()).toList(),
    );
    await prefs.setString(_key, json);
  }

  Future<List<Exercise>> loadRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final rawRoutine = prefs.getString(_key);

    if (rawRoutine == null || rawRoutine.isEmpty) {
      return <Exercise>[];
    }

    try {
      final decoded = jsonDecode(rawRoutine);
      if (decoded is! List) {
        return <Exercise>[];
      }

      return decoded
          .whereType<Map>()
          .map((exercise) => Exercise.fromJson(Map<String, dynamic>.from(exercise)))
          .toList();
    } catch (_) {
      return <Exercise>[];
    }
  }

  Future<void> clearRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
