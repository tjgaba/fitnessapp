class UserProfile {
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

  const UserProfile({
    this.name = 'Alex',
    this.age = 28,
    this.gender = 'Male',
    this.heightCm = 175,
    this.weightKg = 76,
    this.targetWeightKg = 70,
    this.initialWeightKg = 80,
    this.activityLevel = 'Moderate',
    this.restingHeartRate = 72,
    this.goal = 'Lose Weight',
  });

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
    );
  }
}
