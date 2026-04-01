import 'package:flutter/foundation.dart';

import '../../data/repositories/profile_repository.dart';
import '../../data/services/auth_service.dart';
import '../../models/user_profile.dart';
import '../../utils/bmi_calculator.dart';

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
  static const UserProfile _defaultProfile = UserProfile.defaults();

  final ProfileRepository _repository;
  final AuthService _authService;

  UserProfile _profile = _defaultProfile;
  bool _isLoaded = false;
  late final Future<void> _loadFuture;
  String _activeUserId = '';

  ProfileProvider(
    ProfileRepository? repository,
    AuthService? authService,
  )   : _repository = repository ?? ProfileRepository(),
        _authService = authService ?? AuthService() {
    _loadFuture = _init();
    _authService.authStateChanges.listen((_) {
      _reloadForCurrentUser();
    });
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
  String get weightUnit => _profile.weightUnit;
  int get restTimer => _profile.restTimerSeconds;
  bool get notificationsEnabled => _profile.notificationsEnabled;
  bool get isLoaded => _isLoaded;
  bool get isMetric => _profile.weightUnit == 'kg';
  bool get needsProfileCompletion => profileCompleteness < 1;
  bool get hasEssentialProfileDetails =>
      age > 0 &&
      heightCm > 0 &&
      weightKg > 0 &&
      targetWeightKg > 0 &&
      initialWeightKg > 0;

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
    final convertedValue = isMetric ? valueKg : valueKg * 2.2046226218;
    final fractionDigits = convertedValue == convertedValue.roundToDouble()
        ? 0
        : 1;
    return '${convertedValue.toStringAsFixed(fractionDigits)} $weightUnit';
  }

  Future<void> updateName(String value) async {
    final sanitized = value.trim().isEmpty ? _defaultProfile.name : value.trim();
    await _persistProfile(_profile.copyWith(name: sanitized));
  }

  Future<void> updateAge(int value) async {
    await _persistProfile(_profile.copyWith(age: value.clamp(10, 100)));
  }

  Future<void> updateGender(String value) async {
    final sanitized =
        _allowedGenders.contains(value) ? value : _defaultProfile.gender;
    await _persistProfile(_profile.copyWith(gender: sanitized));
  }

  Future<void> updateHeightCm(double value) async {
    await _persistProfile(
      _profile.copyWith(heightCm: value.clamp(120.0, 220.0)),
    );
  }

  Future<void> updateWeightKg(double value) async {
    await _persistProfile(
      _profile.copyWith(weightKg: value.clamp(30.0, 200.0)),
    );
  }

  Future<void> updateTargetWeightKg(double value) async {
    await _persistProfile(
      _profile.copyWith(targetWeightKg: value.clamp(30.0, 200.0)),
    );
  }

  Future<void> updateInitialWeightKg(double value) async {
    await _persistProfile(
      _profile.copyWith(initialWeightKg: value.clamp(30.0, 200.0)),
    );
  }

  Future<void> updateActivityLevel(String value) async {
    final sanitized = _allowedActivityLevels.contains(value)
        ? value
        : _defaultProfile.activityLevel;
    await _persistProfile(_profile.copyWith(activityLevel: sanitized));
  }

  Future<void> updateRestingHeartRate(double value) async {
    await _persistProfile(
      _profile.copyWith(restingHeartRate: value.clamp(40.0, 120.0)),
    );
  }

  Future<void> updateGoal(String value) async {
    final sanitized = _allowedGoals.contains(value) ? value : _defaultProfile.goal;
    await _persistProfile(_profile.copyWith(goal: sanitized));
  }

  Future<void> saveWeightUnit(String value) async {
    final sanitized =
        _allowedWeightUnits.contains(value) ? value : _defaultProfile.weightUnit;
    await _persistProfile(_profile.copyWith(weightUnit: sanitized));
  }

  Future<void> saveRestTimer(int value) async {
    await _persistProfile(
      _profile.copyWith(restTimerSeconds: value.clamp(15, 300)),
    );
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _persistProfile(_profile.copyWith(notificationsEnabled: enabled));
  }

  Future<void> resetProfile() async {
    await _ensureLoaded();
    _profile = _seedProfileForCurrentUser(const UserProfile.defaults());
    notifyListeners();
    await _repository.clearProfile(_activeUserId);
  }

  Future<void> resetPreferences() async {
    await _ensureLoaded();
    _profile = _profile.copyWith(
      weightUnit: _defaultProfile.weightUnit,
      restTimerSeconds: _defaultProfile.restTimerSeconds,
      notificationsEnabled: _defaultProfile.notificationsEnabled,
    );
    notifyListeners();
    await _repository.saveProfile(_activeUserId, _profile);
  }

  Future<void> resetAll() async {
    await resetProfile();
  }

  Future<void> _init() async {
    _activeUserId = _authService.currentUser?.uid ?? '';
    final loadedProfile = await _repository.loadProfile(_activeUserId);
    _profile = _seedProfileForCurrentUser(loadedProfile);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persistProfile(UserProfile profile) async {
    await _ensureLoaded();
    _profile = profile;
    notifyListeners();
    await _repository.saveProfile(_activeUserId, _profile);
  }

  Future<void> _ensureLoaded() async {
    if (_isLoaded) {
      return;
    }

    await _loadFuture;
  }

  Future<void> _reloadForCurrentUser() async {
    final userId = _authService.currentUser?.uid ?? '';
    _activeUserId = userId;
    final loadedProfile = await _repository.loadProfile(userId);
    _profile = _seedProfileForCurrentUser(loadedProfile);
    _isLoaded = true;
    notifyListeners();
  }

  UserProfile _seedProfileForCurrentUser(UserProfile profile) {
    final email = _authService.currentUser?.email?.trim();
    final fallbackName = _emailPrefix(email);
    final currentName = profile.name.trim();

    if (fallbackName.isEmpty) {
      return profile;
    }

    if (currentName.isEmpty || currentName == _defaultProfile.name) {
      return profile.copyWith(name: fallbackName);
    }

    return profile;
  }

  String _emailPrefix(String? email) {
    if (email == null || email.isEmpty || !email.contains('@')) {
      return '';
    }

    final prefix = email.split('@').first.trim();
    if (prefix.isEmpty) {
      return '';
    }

    return prefix[0].toUpperCase() + prefix.substring(1);
  }
}
