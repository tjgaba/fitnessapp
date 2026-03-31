import 'package:flutter/foundation.dart';

import '../data/exercise_api_repository.dart';
import '../data/models/api_exercise.dart';

class ExerciseSearchProvider extends ChangeNotifier {
  final ExerciseApiRepository _repository;

  List<ApiExercise> _searchResults = <ApiExercise>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _lastType = '';
  String? _lastMuscle;

  ExerciseSearchProvider([ExerciseApiRepository? repository])
      : _repository = repository ?? ExerciseApiRepository();

  List<ApiExercise> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get lastType => _lastType;
  String? get lastMuscle => _lastMuscle;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasError => _errorMessage != null;

  Future<void> searchExercises({
    required String type,
    String? muscle,
  }) async {
    final normalizedType = type.trim().toLowerCase();
    final normalizedMuscle = (muscle ?? '').trim().toLowerCase();
    if (normalizedType.isEmpty) {
      return;
    }

    _lastType = normalizedType;
    _lastMuscle = normalizedMuscle.isEmpty ? null : normalizedMuscle;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _repository.searchExercises(
        type: normalizedType,
        muscle: _lastMuscle,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _searchResults = <ApiExercise>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (_lastType.isEmpty) {
      return;
    }

    await searchExercises(
      type: _lastType,
      muscle: _lastMuscle,
    );
  }

  void clearResults() {
    _searchResults = <ApiExercise>[];
    _isLoading = false;
    _errorMessage = null;
    _lastType = '';
    _lastMuscle = null;
    notifyListeners();
  }
}
