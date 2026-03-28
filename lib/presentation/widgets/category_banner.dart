import 'package:flutter/material.dart';
import '../../models/workout_category.dart';
import 'metric_card.dart';

/// Banner shown at the top of each individual category screen.
/// Shows category-specific stats only — no BMI.
class CategoryBanner extends StatelessWidget {
  final WorkoutCategory category;
  final int sessionsCompleted;
  final int sessionsGoalPerWeek;

  const CategoryBanner({
    super.key,
    required this.category,
    required this.sessionsCompleted,
    required this.sessionsGoalPerWeek,
  });

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    final progress = sessionsGoalPerWeek == 0
        ? 0.0
        : sessionsCompleted / sessionsGoalPerWeek;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(category.icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Stats row 1
          Row(
            children: [
              MetricCard(
                label: 'Sessions',
                value: '$sessionsCompleted',
                sub: 'completed',
                color: color,
              ),
              const SizedBox(width: 8),
              MetricCard(
                label: 'Time Spent',
                value: category.totalTime,
                sub: 'total',
                color: color,
              ),
              const SizedBox(width: 8),
              MetricCard(
                label: 'Intensity',
                value: category.intensity,
                sub: 'level',
                color: color,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Stats row 2
          Row(
            children: [
              MetricCard(
                label: 'Calories Burned',
                value: '${category.caloriesBurned} kcal',
                sub: 'estimated',
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              MetricCard(
                label: 'Est. Fat Loss',
                value: '~${category.estimatedFatLossKg} kg',
                sub: 'this week',
                color: Colors.pinkAccent,
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),

          const SizedBox(height: 14),

          // Weekly progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Progress',
                  style: TextStyle(fontSize: 11, color: Colors.black54)),
              Text(
                '$sessionsCompleted / $sessionsGoalPerWeek sessions',
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}


