import 'package:flutter/foundation.dart';

import '../../data/repositories/routine_repository.dart';
import '../../models/exercise.dart';

class RoutineProvider extends ChangeNotifier {
  final RoutineRepository _repository;
  final List<Exercise> _routine = <Exercise>[];
  final Set<String> _completedExerciseIds = <String>{};
  bool _isLoaded = false;
  late final Future<void> _loadFuture;

  RoutineProvider([RoutineRepository? repository])
      : _repository = repository ?? RoutineRepository() {
    _loadFuture = _init();
  }

  List<Exercise> get routine => List.unmodifiable(_routine);
  Set<String> get completedExerciseIds => Set.unmodifiable(_completedExerciseIds);
  bool get isLoaded => _isLoaded;

  int get exerciseCount => _routine.length;
  int get completedExerciseCount =>
      _routine.where((exercise) => _completedExerciseIds.contains(exercise.id)).length;
  int get remainingExerciseCount => exerciseCount - completedExerciseCount;
  bool get hasRoutine => _routine.isNotEmpty;
  bool get isRoutineComplete =>
      hasRoutine && completedExerciseCount == exerciseCount;
  double get completionProgress =>
      hasRoutine ? completedExerciseCount / exerciseCount : 0;

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

  Future<void> addExercise(Exercise exercise) async {
    await _ensureLoaded();
    if (isInRoutine(exercise.id)) {
      return;
    }

    _routine.add(exercise);
    notifyListeners();
    await _repository.saveRoutine(_routine);
  }

  Future<void> removeExercise(String id) async {
    await _ensureLoaded();
    final originalLength = _routine.length;
    _routine.removeWhere((exercise) => exercise.id == id);
    final removedCompletion = _completedExerciseIds.remove(id);
    if (_routine.length == originalLength && !removedCompletion) {
      return;
    }

    notifyListeners();
    await _repository.saveRoutine(_routine);
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

  Future<void> clearRoutine() async {
    await _ensureLoaded();
    if (_routine.isEmpty && _completedExerciseIds.isEmpty) {
      return;
    }

    _routine.clear();
    _completedExerciseIds.clear();
    notifyListeners();
    await _repository.clearRoutine();
  }

  Future<void> _init() async {
    _routine
      ..clear()
      ..addAll(await _repository.loadRoutine());
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _ensureLoaded() async {
    if (_isLoaded) {
      return;
    }

    await _loadFuture;
  }
}
