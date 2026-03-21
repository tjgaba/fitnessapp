import 'package:flutter/foundation.dart';

import '../models/custom_exercise.dart';

class CustomExerciseStore {
  CustomExerciseStore._();

  static final ValueNotifier<List<CustomExercise>> exercises =
      ValueNotifier<List<CustomExercise>>(<CustomExercise>[]);

  static void add(CustomExercise exercise) {
    exercises.value = [exercise, ...exercises.value];
  }

  static void toggleCompleted(String id) {
    exercises.value = exercises.value
        .map(
          (exercise) => exercise.id == id
              ? exercise.copyWith(completed: !exercise.completed)
              : exercise,
        )
        .toList();
  }
}
