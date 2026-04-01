import r'package:flutter/material.dart';

import '../../models/workout_category.dart';

class ExerciseCategoryDefinition {
  final String apiType;
  final WorkoutCategory category;

  const ExerciseCategoryDefinition({
    required this.apiType,
    required this.category,
  });
}

const List<ExerciseCategoryDefinition> exerciseCategoryDefinitions = [
  ExerciseCategoryDefinition(
    apiType: 'strength',
    category: WorkoutCategory(
      title: 'Strength',
      icon: Icons.fitness_center,
      color: Colors.blueAccent,
      sessionsCompleted: 2,
      sessionsGoalPerWeek: 4,
      totalTime: '4h 00m',
      caloriesBurned: 620,
      estimatedFatLossKg: 0.08,
      intensity: 'Moderate-High',
    ),
  ),
  ExerciseCategoryDefinition(
    apiType: 'cardio',
    category: WorkoutCategory(
      title: 'Cardio',
      icon: Icons.directions_run,
      color: Colors.pinkAccent,
      sessionsCompleted: 3,
      sessionsGoalPerWeek: 4,
      totalTime: '5h 30m',
      caloriesBurned: 970,
      estimatedFatLossKg: 0.13,
      intensity: 'Moderate',
    ),
  ),
  ExerciseCategoryDefinition(
    apiType: 'stretching',
    category: WorkoutCategory(
      title: 'Stretching',
      icon: Icons.self_improvement,
      color: Colors.greenAccent,
      sessionsCompleted: 1,
      sessionsGoalPerWeek: 4,
      totalTime: '1h 40m',
      caloriesBurned: 150,
      estimatedFatLossKg: 0.02,
      intensity: 'Low',
    ),
  ),
  ExerciseCategoryDefinition(
    apiType: 'plyometrics',
    category: WorkoutCategory(
      title: 'Plyometrics',
      icon: Icons.flash_on,
      color: Colors.orangeAccent,
      sessionsCompleted: 2,
      sessionsGoalPerWeek: 4,
      totalTime: '3h 10m',
      caloriesBurned: 890,
      estimatedFatLossKg: 0.12,
      intensity: 'High',
    ),
  ),
  ExerciseCategoryDefinition(
    apiType: 'weightlifting',
    category: WorkoutCategory(
      title: 'Weightlifting',
      icon: Icons.sports_gymnastics,
      color: Colors.deepPurpleAccent,
      sessionsCompleted: 1,
      sessionsGoalPerWeek: 3,
      totalTime: '2h 15m',
      caloriesBurned: 340,
      estimatedFatLossKg: 0.04,
      intensity: 'High',
    ),
  ),
  ExerciseCategoryDefinition(
    apiType: 'strongman',
    category: WorkoutCategory(
      title: 'Strongman',
      icon: Icons.hardware,
      color: Colors.brown,
      sessionsCompleted: 1,
      sessionsGoalPerWeek: 2,
      totalTime: '2h 00m',
      caloriesBurned: 410,
      estimatedFatLossKg: 0.05,
      intensity: 'High',
    ),
  ),
];

final List<WorkoutCategory> appCategories = List<WorkoutCategory>.unmodifiable(
  exerciseCategoryDefinitions.map((definition) => definition.category),
);

final List<String> apiExerciseTypes = List<String>.unmodifiable(
  exerciseCategoryDefinitions.map((definition) => definition.apiType),
);

ExerciseCategoryDefinition? exerciseCategoryForTitle(String categoryTitle) {
  final normalizedTitle = categoryTitle.trim().toLowerCase();

  for (final definition in exerciseCategoryDefinitions) {
    final matchesPrimary =
        definition.category.title.trim().toLowerCase() == normalizedTitle;
    if (matchesPrimary) {
      return definition;
    }
  }

  return null;
}

String apiTypeForCategory(String categoryTitle) {
  return exerciseCategoryForTitle(categoryTitle)?.apiType ?? '';
}

List<String> categoryNamesForMatching(String categoryTitle) {
  final definition = exerciseCategoryForTitle(categoryTitle);
  if (definition != null) {
    return <String>[definition.category.title];
  }

  return <String>[categoryTitle];
}

bool categoryMatches(String categoryTitle, String value) {
  final normalizedValue = value.trim().toLowerCase();
  return categoryNamesForMatching(
    categoryTitle,
  ).any((name) => name.trim().toLowerCase() == normalizedValue);
}
