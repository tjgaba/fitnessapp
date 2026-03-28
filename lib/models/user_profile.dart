class UserProfile {
  static const Set<String> _allowedWeightUnits = {'kg', 'lbs'};

  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double targetWeightKg;
  final double initialWeightKg;
  final String activityLevel;
  final double restingHeartRate;
  final String goal;
  final String weightUnit;
  final int restTimerSeconds;
  final bool notificationsEnabled;

  const UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.targetWeightKg,
    required this.initialWeightKg,
    required this.activityLevel,
    required this.restingHeartRate,
    required this.goal,
    required this.weightUnit,
    required this.restTimerSeconds,
    required this.notificationsEnabled,
  });

  const UserProfile.defaults()
      : name = 'Guest',
        age = 0,
        gender = 'Male',
        heightCm = 175,
        weightKg = 0.0,
        targetWeightKg = 0.0,
        initialWeightKg = 0.0,
        activityLevel = 'Moderate',
        restingHeartRate = 72.0,
        goal = 'Lose Weight',
        weightUnit = 'kg',
        restTimerSeconds = 60,
        notificationsEnabled = true;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'targetWeightKg': targetWeightKg,
      'initialWeightKg': initialWeightKg,
      'activityLevel': activityLevel,
      'restingHeartRate': restingHeartRate,
      'goal': goal,
      'weightUnit': weightUnit,
      'restTimerSeconds': restTimerSeconds,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final defaults = const UserProfile.defaults();

    final age = _parseInt(json['age']);
    final weightGoal = _parseDouble(json['weightGoal']);
    final targetWeight = _parseDouble(json['targetWeightKg']);
    final weightUnit = json['weightUnit'] is String ? json['weightUnit'] as String : defaults.weightUnit;
    final restTimer = _parseInt(json['restTimerSeconds']);

    return UserProfile(
      name: json['name'] is String ? json['name'] as String : defaults.name,
      age: age == null || age < 0 || age > 120 ? defaults.age : age,
      gender: json['gender'] is String ? json['gender'] as String : defaults.gender,
      heightCm: _parseDouble(json['heightCm']) ?? defaults.heightCm,
      weightKg: _nonNegativeOrDefault(_parseDouble(json['weightKg']), defaults.weightKg),
      targetWeightKg: _nonNegativeOrDefault(
        targetWeight ?? weightGoal,
        defaults.targetWeightKg,
      ),
      initialWeightKg: _nonNegativeOrDefault(
        _parseDouble(json['initialWeightKg']),
        defaults.initialWeightKg,
      ),
      activityLevel: json['activityLevel'] is String
          ? json['activityLevel'] as String
          : defaults.activityLevel,
      restingHeartRate: _positiveOrDefault(
        _parseDouble(json['restingHeartRate']),
        defaults.restingHeartRate,
      ),
      goal: json['goal'] is String ? json['goal'] as String : defaults.goal,
      weightUnit: _allowedWeightUnits.contains(weightUnit)
          ? weightUnit
          : defaults.weightUnit,
      restTimerSeconds: _clamp(restTimer ?? defaults.restTimerSeconds, 15, 300),
      notificationsEnabled: json['notificationsEnabled'] is bool
          ? json['notificationsEnabled'] as bool
          : defaults.notificationsEnabled,
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    double? initialWeightKg,
    String? activityLevel,
    double? restingHeartRate,
    String? goal,
    String? weightUnit,
    int? restTimerSeconds,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      initialWeightKg: initialWeightKg ?? this.initialWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      goal: goal ?? this.goal,
      weightUnit: weightUnit ?? this.weightUnit,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static double _nonNegativeOrDefault(double? value, double fallback) {
    if (value == null || value < 0) {
      return fallback;
    }
    return value;
  }

  static double _positiveOrDefault(double? value, double fallback) {
    if (value == null || value <= 0) {
      return fallback;
    }
    return value;
  }

  static int _clamp(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }
}
