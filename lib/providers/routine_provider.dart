import 'package:flutter/foundation.dart';

import '../models/exercise.dart';

class RoutineProvider extends ChangeNotifier {
  final List<Exercise> _routine = [];
  final Set<String> _completedExerciseIds = <String>{};

  List<Exercise> get routine => List.unmodifiable(_routine);
  Set<String> get completedExerciseIds => Set.unmodifiable(_completedExerciseIds);

  int get exerciseCount => _routine.length;
  int get completedExerciseCount => _routine.where((exercise) => _completedExerciseIds.contains(exercise.id)).length;
  int get remainingExerciseCount => exerciseCount - completedExerciseCount;
  bool get hasRoutine => _routine.isNotEmpty;
  bool get isRoutineComplete => hasRoutine && completedExerciseCount == exerciseCount;
  double get completionProgress => hasRoutine ? completedExerciseCount / exerciseCount : 0;

  int get totalSets => _routine.fold(
    0,
    (sum, exercise) => sum + exercise.sets,
  );

  double get totalVolume => _routine.fold(
    0,
    (sum, exercise) => sum + exercise.volume,
  );

  Map<String, int> get muscleGroupBreakdown {
    final breakdown = <String, int>{};
    for (final exercise in _routine) {
      breakdown.update(
        exercise.muscleGroup,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return breakdown;
  }

  bool isInRoutine(String id) {
    return _routine.any((exercise) => exercise.id == id);
  }

  bool isExerciseCompleted(String id) {
    return _completedExerciseIds.contains(id);
  }

  void addExercise(Exercise exercise) {
    if (isInRoutine(exercise.id)) {
      return;
    }

    _routine.add(exercise);
    notifyListeners();
  }

  void removeExercise(String id) {
    final originalLength = _routine.length;
    _routine.removeWhere((exercise) => exercise.id == id);
    final removedCompletion = _completedExerciseIds.remove(id);
    if (_routine.length != originalLength || removedCompletion) {
      notifyListeners();
    }
  }

  void toggleExerciseCompleted(String id, bool completed) {
    if (!isInRoutine(id)) {
      return;
    }

    final changed = completed
        ? _completedExerciseIds.add(id)
        : _completedExerciseIds.remove(id);

    if (changed) {
      notifyListeners();
    }
  }

  void clearRoutine() {
    if (_routine.isEmpty && _completedExerciseIds.isEmpty) {
      return;
    }

    _routine.clear();
    _completedExerciseIds.clear();
    notifyListeners();
  }
}
