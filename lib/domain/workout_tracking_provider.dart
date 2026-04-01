import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/location_service.dart';
import '../models/outdoor_workout_record.dart';

enum WorkoutPhase { idle, active, finished }

class WorkoutTrackingProvider extends ChangeNotifier {
  static const String _historyKey = 'outdoor_workout_history';

  final LocationService _locationService;

  WorkoutPhase _workoutPhase = WorkoutPhase.idle;
  Position? _startPosition;
  Position? _endPosition;
  Position? _currentPosition;
  double _distanceMeters = 0.0;
  double _routeDistanceMeters = 0.0;
  DateTime? _startTime;
  int _elapsedSeconds = 0;
  String? _errorMessage;
  bool _isLoadingLocation = false;
  final List<Position> _routePoints = <Position>[];
  final List<OutdoorWorkoutRecord> _history = <OutdoorWorkoutRecord>[];

  Timer? _elapsedTimer;
  Timer? _routePollingTimer;

  WorkoutTrackingProvider([LocationService? locationService])
      : _locationService = locationService ?? LocationService() {
    _loadHistory();
  }

  WorkoutPhase get workoutPhase => _workoutPhase;
  Position? get startPosition => _startPosition;
  Position? get endPosition => _endPosition;
  Position? get currentPosition => _currentPosition;
  double get distanceMeters => _distanceMeters;
  double get routeDistanceMeters => _routeDistanceMeters;
  DateTime? get startTime => _startTime;
  int get elapsedSeconds => _elapsedSeconds;
  String? get errorMessage => _errorMessage;
  bool get isLoadingLocation => _isLoadingLocation;
  List<Position> get routePoints => List<Position>.unmodifiable(_routePoints);
  List<OutdoorWorkoutRecord> get history =>
      List<OutdoorWorkoutRecord>.unmodifiable(_history);
  bool get canFinish => _workoutPhase == WorkoutPhase.active;
  bool get hasRoutePoints => _routePoints.isNotEmpty;
  bool get hasHistory => _history.isNotEmpty;

  String get formattedTime {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  String get formattedDistance => _formatDistance(_distanceMeters);
  String get formattedStraightLineDistance => _formatDistance(_distanceMeters);
  String get formattedRouteDistance => _formatDistance(_routeDistanceMeters);

  String get formattedPace {
    final paceDistanceMeters =
        _routeDistanceMeters > 0 ? _routeDistanceMeters : _distanceMeters;
    if (paceDistanceMeters <= 0 || _elapsedSeconds <= 0) {
      return '--';
    }

    final totalMinutes = _elapsedSeconds / 60;
    final distanceKm = paceDistanceMeters / 1000;
    final paceMinutesPerKm = totalMinutes / distanceKm;
    final wholeMinutes = paceMinutesPerKm.floor();
    final seconds = ((paceMinutesPerKm - wholeMinutes) * 60).round();

    final normalizedMinutes = seconds == 60 ? wholeMinutes + 1 : wholeMinutes;
    final normalizedSeconds = seconds == 60 ? 0 : seconds;

    return '$normalizedMinutes:${normalizedSeconds.toString().padLeft(2, '0')} min/km';
  }

  Future<void> startWorkout() async {
    _cancelTimers();
    _isLoadingLocation = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      _startPosition = position;
      _currentPosition = position;
      _endPosition = null;
      _distanceMeters = 0.0;
      _routeDistanceMeters = 0.0;
      _routePoints
        ..clear()
        ..add(position);
      _elapsedSeconds = 0;
      _startTime = DateTime.now();
      _workoutPhase = WorkoutPhase.active;
      _startElapsedTimer();
      _startRoutePolling();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _workoutPhase = WorkoutPhase.idle;
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation() async {
    if (_workoutPhase != WorkoutPhase.active) {
      return;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      _currentPosition = position;
      _routePoints.add(position);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> finishWorkout() async {
    _isLoadingLocation = true;
    _cancelTimers();
    notifyListeners();

    try {
      final endPosition = await _locationService.getCurrentPosition();
      _endPosition = endPosition;
      _currentPosition = endPosition;
      _routePoints.add(endPosition);

      final startPosition = _startPosition;
      if (startPosition != null) {
        _distanceMeters = _locationService.calculateDistance(
          startPosition.latitude,
          startPosition.longitude,
          endPosition.latitude,
          endPosition.longitude,
        );
      }

      _routeDistanceMeters = _calculateRouteDistance();
      await _persistCurrentWorkout();
      _workoutPhase = WorkoutPhase.finished;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _routeDistanceMeters = _calculateRouteDistance();
      await _persistCurrentWorkout();
      _workoutPhase = WorkoutPhase.finished;
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void resetWorkout() {
    _cancelTimers();
    _workoutPhase = WorkoutPhase.idle;
    _startPosition = null;
    _endPosition = null;
    _currentPosition = null;
    _distanceMeters = 0.0;
    _routeDistanceMeters = 0.0;
    _startTime = null;
    _elapsedSeconds = 0;
    _errorMessage = null;
    _isLoadingLocation = false;
    _routePoints.clear();
    notifyListeners();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds += 1;
      notifyListeners();
    });
  }

  void _startRoutePolling() {
    _routePollingTimer?.cancel();
    _routePollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_workoutPhase != WorkoutPhase.active) {
        return;
      }

      try {
        final position = await _locationService.getCurrentPosition();
        _currentPosition = position;
        _routePoints.add(position);
        notifyListeners();
      } catch (_) {
        // Skip transient GPS failures during route polling.
      }
    });
  }

  void _cancelTimers() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _routePollingTimer?.cancel();
    _routePollingTimer = null;
  }

  double _calculateRouteDistance() {
    if (_routePoints.length < 2) {
      return 0.0;
    }

    double totalDistance = 0.0;
    for (var index = 1; index < _routePoints.length; index += 1) {
      final previousPoint = _routePoints[index - 1];
      final currentPoint = _routePoints[index];
      totalDistance += _locationService.calculateDistance(
        previousPoint.latitude,
        previousPoint.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );
    }
    return totalDistance;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawHistory = prefs.getString(_historyKey);
    if (rawHistory == null || rawHistory.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(rawHistory);
      if (decoded is! List) {
        return;
      }

      _history
        ..clear()
        ..addAll(
          decoded
              .whereType<Map>()
              .map(
                (item) => OutdoorWorkoutRecord.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              ),
        );
      notifyListeners();
    } catch (_) {
      // Ignore malformed persisted history.
    }
  }

  Future<void> _persistCurrentWorkout() async {
    final startedAt = _startTime;
    if (startedAt == null) {
      return;
    }

    final record = OutdoorWorkoutRecord(
      id: startedAt.millisecondsSinceEpoch.toString(),
      startedAt: startedAt,
      elapsedSeconds: _elapsedSeconds,
      straightLineDistanceMeters: _distanceMeters,
      routeDistanceMeters: _routeDistanceMeters,
      startPosition: _startPosition,
      endPosition: _endPosition,
      routePoints: List<Position>.from(_routePoints),
    );

    _history.removeWhere((entry) => entry.id == record.id);
    _history.insert(0, record);
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      _history.map((entry) => entry.toJson()).toList(),
    );
    await prefs.setString(_historyKey, payload);
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
