class ProgressStats {
  final double initialWeightKg;
  final double currentWeightKg;
  final int totalSteps;
  final int totalCaloriesBurned;
  final double estimatedFatLossKg;
  final String totalExerciseTime;
  final double workoutCompletionPercent; // 0.0 – 1.0

  const ProgressStats({
    required this.initialWeightKg,
    required this.currentWeightKg,
    required this.totalSteps,
    required this.totalCaloriesBurned,
    required this.estimatedFatLossKg,
    required this.totalExerciseTime,
    required this.workoutCompletionPercent,
  });

  double get weightChange => currentWeightKg - initialWeightKg;
}
