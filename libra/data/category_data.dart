import 'package:flutter/material.dart';
import '../models/workout_category.dart';

final List<WorkoutCategory> appCategories = [
  WorkoutCategory(
    title: 'HIIT',
    icon: Icons.flash_on,
    color: Colors.orangeAccent,
    sessionsCompleted: 2,
    sessionsGoalPerWeek: 4,
    totalTime: '3h 10m',
    caloriesBurned: 890,
    estimatedFatLossKg: 0.12,
    intensity: 'High',
  ),
  WorkoutCategory(
    title: 'Strength',
    icon: Icons.fitness_center,
    color: Colors.blueAccent,
    sessionsCompleted: 2,
    sessionsGoalPerWeek: 4,
    totalTime: '4h 00m',
    caloriesBurned: 620,
    estimatedFatLossKg: 0.08,
    intensity: 'Moderate–High',
  ),
  WorkoutCategory(
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
  WorkoutCategory(
    title: 'Flexibility',
    icon: Icons.self_improvement,
    color: Colors.greenAccent,
    sessionsCompleted: 1,
    sessionsGoalPerWeek: 4,
    totalTime: '1h 40m',
    caloriesBurned: 150,
    estimatedFatLossKg: 0.02,
    intensity: 'Low',
  ),
];
