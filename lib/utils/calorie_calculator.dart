import '../data/reference/met_values.dart';

/// Calories Burned = MET × weight (kg) × duration (hours)
double estimateCaloriesBurned({
  required String category,
  required double weightKg,
  required double durationMinutes,
}) {
  final met = metValues[category] ?? 5.0;
  final hours = durationMinutes / 60;
  return met * weightKg * hours;
}
