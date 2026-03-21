import 'package:flutter/material.dart';

class WorkoutCategory {
  final String title;
  final IconData icon;
  final Color color;
  final int sessionsCompleted;
  final int sessionsGoalPerWeek;
  final String totalTime;
  final int caloriesBurned;
  final double estimatedFatLossKg;
  final String intensity;

  const WorkoutCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.sessionsCompleted,
    required this.sessionsGoalPerWeek,
    required this.totalTime,
    required this.caloriesBurned,
    required this.estimatedFatLossKg,
    required this.intensity,
  });
}
