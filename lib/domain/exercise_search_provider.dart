import 'package:flutter/foundation.dart';

import '../data/exercise_api_repository.dart';
import '../data/models/api_exercise.dart';

class ExerciseSearchProvider extends ChangeNotifier {
  final ExerciseApiRepository _repository;

  List<ApiExercise> _searchResults = <ApiExercise>[];
  bool _isLoading = false;
  String? _errorMessage;
  String _lastQuery = '';

  ExerciseSearchProvider([ExerciseApiRepository? repository])
      : _repository = repository ?? ExerciseApiRepository();

  List<ApiExercise> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasError => _errorMessage != null;

  Future<void> searchExercises(String muscle) async {
    final query = muscle.trim().toLowerCase();
    if (query.isEmpty) {
      return;
    }

    _lastQuery = query;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _repository.searchExercises(query);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _searchResults = <ApiExercise>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (_lastQuery.isEmpty) {
      return;
    }

    await searchExercises(_lastQuery);
  }

  void clearResults() {
    _searchResults = <ApiExercise>[];
    _isLoading = false;
    _errorMessage = null;
    _lastQuery = '';
    notifyListeners();
  }
}
