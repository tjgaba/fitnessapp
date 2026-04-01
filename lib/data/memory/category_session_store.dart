import 'package:flutter/foundation.dart';

import '../../models/category_session.dart';
import '../../models/workout_category.dart';

class CategorySessionStore {
  CategorySessionStore._();

  static final ValueNotifier<Map<String, List<CategorySession>>> sessionsByCategory =
      ValueNotifier<Map<String, List<CategorySession>>>({});

  static void ensureCategory(WorkoutCategory category) {
    if (sessionsByCategory.value.containsKey(category.title)) {
      return;
    }

    final sessions = List<CategorySession>.generate(
      category.sessionsGoalPerWeek,
      (index) => CategorySession(
        index: index + 1,
        completed: index < category.sessionsCompleted,
      ),
    );

    sessionsByCategory.value = {
      ...sessionsByCategory.value,
      category.title: sessions,
    };
  }

  static List<CategorySession> sessionsFor(String categoryTitle) {
    return sessionsByCategory.value[categoryTitle] ?? const [];
  }

  static bool addExercisesToNextSession(
    String categoryTitle,
    List<String> exerciseIds,
  ) {
    final sessions = sessionsFor(categoryTitle);
    if (sessions.isEmpty) {
      return false;
    }

    final targetIndex = sessions.indexWhere((session) => session.exerciseIds.isEmpty);
    if (targetIndex == -1) {
      return false;
    }

    final updated = [...sessions];
    updated[targetIndex] = updated[targetIndex].copyWith(
      exerciseIds: List<String>.from(exerciseIds),
    );

    sessionsByCategory.value = {
      ...sessionsByCategory.value,
      categoryTitle: updated,
    };
    return true;
  }

  static void toggleSessionCompletion(String categoryTitle, int sessionIndex) {
    final sessions = sessionsFor(categoryTitle);
    if (sessions.isEmpty) {
      return;
    }

    final updated = sessions
        .map(
          (session) => session.index == sessionIndex
              ? session.copyWith(completed: !session.completed)
              : session,
        )
        .toList();

    sessionsByCategory.value = {
      ...sessionsByCategory.value,
      categoryTitle: updated,
    };
  }
}
