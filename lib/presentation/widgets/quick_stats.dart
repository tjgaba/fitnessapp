import 'package:flutter/material.dart';

/// A horizontal row of quick-glance stat chips for the home screen.
class QuickStats extends StatelessWidget {
  final int totalSteps;
  final int totalCalories;
  final String totalExerciseTime;

  const QuickStats({
    super.key,
    required this.totalSteps,
    required this.totalCalories,
    required this.totalExerciseTime,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Steps', 'value': totalSteps.toString(), 'color': Colors.green},
      {'label': 'Calories', 'value': '$totalCalories kcal', 'color': Colors.orange},
      {'label': 'Time', 'value': totalExerciseTime, 'color': Colors.purple},
    ];

    return Row(
      children: stats.map((s) {
        final color = s['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  s['value'] as String,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['label'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}


