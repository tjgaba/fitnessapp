import 'package:flutter/foundation.dart';

import '../models/exercise.dart';

class RoutineProvider extends ChangeNotifier {
  final List<Exercise> _routine = [];

  List<Exercise> get routine => List.unmodifiable(_routine);

  int get exerciseCount => _routine.length;

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
    if (_routine.length != originalLength) {
      notifyListeners();
    }
  }

  void clearRoutine() {
    if (_routine.isEmpty) {
      return;
    }

    _routine.clear();
    notifyListeners();
  }
}
