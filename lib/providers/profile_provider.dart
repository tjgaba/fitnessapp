import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../utils/bmi_calculator.dart';

class ProfileProvider extends ChangeNotifier {
  static const Set<String> _allowedGenders = {
    'Male',
    'Female',
    'Other',
  };
  static const Set<String> _allowedActivityLevels = {
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
    'Very Active',
  };
  static const Set<String> _allowedGoals = {
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Maintain Fitness',
    'Improve Flexibility',
  };
  static const Set<String> _allowedWeightUnits = {'kg', 'lbs'};

  static const String _nameKey = 'profile_name';
  static const String _ageKey = 'profile_age';
  static const String _genderKey = 'profile_gender';
  static const String _heightKey = 'profile_height_cm';
  static const String _weightKey = 'profile_weight_kg';
  static const String _targetWeightKey = 'profile_target_weight_kg';
  static const String _initialWeightKey = 'profile_initial_weight_kg';
  static const String _activityLevelKey = 'profile_activity_level';
  static const String _restingHeartRateKey = 'profile_resting_heart_rate';
  static const String _goalKey = 'profile_goal';
  static const String _weightUnitKey = 'profile_weight_unit';
  static const String _restTimerKey = 'profile_rest_timer';
  static const String _notificationsKey = 'profile_notifications_enabled';

  static const UserProfile _defaultProfile = UserProfile();

  UserProfile _profile = _defaultProfile;
  String _weightUnit = 'kg';
  int _restTimer = 60;
  bool _notificationsEnabled = true;
  bool _isLoaded = false;
  late final Future<void> _loadFuture;

  ProfileProvider() {
    _loadFuture = _loadAll();
  }

  UserProfile get profile => _profile;
  String get name => _profile.name;
  int get age => _profile.age;
  String get gender => _profile.gender;
  double get heightCm => _profile.heightCm;
  double get weightKg => _profile.weightKg;
  double get targetWeightKg => _profile.targetWeightKg;
  double get initialWeightKg => _profile.initialWeightKg;
  String get activityLevel => _profile.activityLevel;
  double get restingHeartRate => _profile.restingHeartRate;
  String get goal => _profile.goal;

  String get weightUnit => _weightUnit;
  int get restTimer => _restTimer;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoaded => _isLoaded;

  double get bmi => calculateBmi(weightKg, heightCm);
  String get bmiCategoryLabel => bmiCategory(bmi);
  double get weightChangeKg => weightKg - initialWeightKg;

  double get profileCompleteness {
    final checks = <bool>[
      name.trim().isNotEmpty,
      age > 0,
      _allowedGenders.contains(gender),
      heightCm > 0,
      weightKg > 0,
      targetWeightKg > 0,
      initialWeightKg > 0,
      _allowedActivityLevels.contains(activityLevel),
      restingHeartRate > 0,
      _allowedGoals.contains(goal),
    ];
    final completed = checks.where((value) => value).length;
    return completed / checks.length;
  }

  String formatWeight(double valueKg) {
    final convertedValue = _weightUnit == 'lbs' ? valueKg * 2.2046226218 : valueKg;
    final fractionDigits = convertedValue == convertedValue.roundToDouble() ? 0 : 1;
    return '${convertedValue.toStringAsFixed(fractionDigits)} $_weightUnit';
  }

  Future<void> updateName(String value) {
    final sanitized = value.trim().isEmpty ? _defaultProfile.name : value.trim();
    return _updateProfile(
      _profile.copyWith(name: sanitized),
      saveOperation: (prefs) => prefs.setString(_nameKey, sanitized),
    );
  }

  Future<void> updateAge(int value) {
    final sanitized = value.clamp(10, 100);
    return _updateProfile(
      _profile.copyWith(age: sanitized),
      saveOperation: (prefs) => prefs.setInt(_ageKey, sanitized),
    );
  }

  Future<void> updateGender(String value) {
    final sanitized = _allowedGenders.contains(value) ? value : _defaultProfile.gender;
    return _updateProfile(
      _profile.copyWith(gender: sanitized),
      saveOperation: (prefs) => prefs.setString(_genderKey, sanitized),
    );
  }

  Future<void> updateHeightCm(double value) {
    final sanitized = value.clamp(120.0, 220.0);
    return _updateProfile(
      _profile.copyWith(heightCm: sanitized),
      saveOperation: (prefs) => prefs.setDouble(_heightKey, sanitized),
    );
  }

  Future<void> updateWeightKg(double value) {
    final sanitized = value.clamp(30.0, 200.0);
    return _updateProfile(
      _profile.copyWith(weightKg: sanitized),
      saveOperation: (prefs) => prefs.setDouble(_weightKey, sanitized),
    );
  }

  Future<void> updateTargetWeightKg(double value) {
    final sanitized = value.clamp(30.0, 200.0);
    return _updateProfile(
      _profile.copyWith(targetWeightKg: sanitized),
      saveOperation: (prefs) => prefs.setDouble(_targetWeightKey, sanitized),
    );
  }

  Future<void> updateInitialWeightKg(double value) {
    final sanitized = value.clamp(30.0, 200.0);
    return _updateProfile(
      _profile.copyWith(initialWeightKg: sanitized),
      saveOperation: (prefs) => prefs.setDouble(_initialWeightKey, sanitized),
    );
  }

  Future<void> updateActivityLevel(String value) {
    final sanitized = _allowedActivityLevels.contains(value)
        ? value
        : _defaultProfile.activityLevel;
    return _updateProfile(
      _profile.copyWith(activityLevel: sanitized),
      saveOperation: (prefs) => prefs.setString(_activityLevelKey, sanitized),
    );
  }

  Future<void> updateRestingHeartRate(double value) {
    final sanitized = value.clamp(40.0, 120.0);
    return _updateProfile(
      _profile.copyWith(restingHeartRate: sanitized),
      saveOperation: (prefs) => prefs.setDouble(_restingHeartRateKey, sanitized),
    );
  }

  Future<void> updateGoal(String value) {
    final sanitized = _allowedGoals.contains(value) ? value : _defaultProfile.goal;
    return _updateProfile(
      _profile.copyWith(goal: sanitized),
      saveOperation: (prefs) => prefs.setString(_goalKey, sanitized),
    );
  }

  Future<void> saveWeightUnit(String value) async {
    await _ensureLoaded();
    final sanitized = _allowedWeightUnits.contains(value) ? value : 'kg';
    _weightUnit = sanitized;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightUnitKey, sanitized);
  }

  Future<void> saveRestTimer(int value) async {
    await _ensureLoaded();
    final sanitized = value.clamp(15, 300);
    _restTimer = sanitized;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_restTimerKey, sanitized);
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _ensureLoaded();
    _notificationsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<void> resetProfile() async {
    await _ensureLoaded();
    _profile = _defaultProfile;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _defaultProfile.name);
    await prefs.setInt(_ageKey, _defaultProfile.age);
    await prefs.setString(_genderKey, _defaultProfile.gender);
    await prefs.setDouble(_heightKey, _defaultProfile.heightCm);
    await prefs.setDouble(_weightKey, _defaultProfile.weightKg);
    await prefs.setDouble(_targetWeightKey, _defaultProfile.targetWeightKg);
    await prefs.setDouble(_initialWeightKey, _defaultProfile.initialWeightKg);
    await prefs.setString(_activityLevelKey, _defaultProfile.activityLevel);
    await prefs.setDouble(
      _restingHeartRateKey,
      _defaultProfile.restingHeartRate,
    );
    await prefs.setString(_goalKey, _defaultProfile.goal);
  }

  Future<void> resetPreferences() async {
    await _ensureLoaded();
    _weightUnit = 'kg';
    _restTimer = 60;
    _notificationsEnabled = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightUnitKey, _weightUnit);
    await prefs.setInt(_restTimerKey, _restTimer);
    await prefs.setBool(_notificationsKey, _notificationsEnabled);
  }

  Future<void> resetAll() async {
    await _ensureLoaded();
    _profile = _defaultProfile;
    _weightUnit = 'kg';
    _restTimer = 60;
    _notificationsEnabled = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final storedGender = prefs.getString(_genderKey);
    final storedActivityLevel = prefs.getString(_activityLevelKey);
    final storedGoal = prefs.getString(_goalKey);
    final storedWeightUnit = prefs.getString(_weightUnitKey);

    _profile = UserProfile(
      name: prefs.getString(_nameKey) ?? _defaultProfile.name,
      age: (prefs.getInt(_ageKey) ?? _defaultProfile.age).clamp(10, 100),
      gender: _allowedGenders.contains(storedGender)
          ? storedGender!
          : _defaultProfile.gender,
      heightCm: (prefs.getDouble(_heightKey) ?? _defaultProfile.heightCm)
          .clamp(120.0, 220.0),
      weightKg: (prefs.getDouble(_weightKey) ?? _defaultProfile.weightKg)
          .clamp(30.0, 200.0),
      targetWeightKg:
          (prefs.getDouble(_targetWeightKey) ?? _defaultProfile.targetWeightKg)
              .clamp(30.0, 200.0),
      initialWeightKg:
          (prefs.getDouble(_initialWeightKey) ?? _defaultProfile.initialWeightKg)
              .clamp(30.0, 200.0),
      activityLevel: _allowedActivityLevels.contains(storedActivityLevel)
          ? storedActivityLevel!
          : _defaultProfile.activityLevel,
      restingHeartRate:
          (prefs.getDouble(_restingHeartRateKey) ?? _defaultProfile.restingHeartRate)
              .clamp(40.0, 120.0),
      goal: _allowedGoals.contains(storedGoal) ? storedGoal! : _defaultProfile.goal,
    );
    _weightUnit = _allowedWeightUnits.contains(storedWeightUnit)
        ? storedWeightUnit!
        : 'kg';
    _restTimer = (prefs.getInt(_restTimerKey) ?? 60).clamp(15, 300);
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _updateProfile(
    UserProfile profile, {
    required Future<bool> Function(SharedPreferences prefs) saveOperation,
  }) async {
    await _ensureLoaded();
    _profile = profile;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await saveOperation(prefs);
  }

  Future<void> _ensureLoaded() async {
    if (_isLoaded) {
      return;
    }

    await _loadFuture;
  }
}
