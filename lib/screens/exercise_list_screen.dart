import 'package:flutter/material.dart';

import '../app_router.dart';
import '../data/custom_exercise_store.dart';
import '../models/custom_exercise.dart';
import '../widgets/app_drawer.dart';

class ExerciseListScreen extends StatelessWidget {
  final String categoryName;
  final Color themeColor;
  final IconData iconData;

  const ExerciseListScreen({
    super.key,
    required this.categoryName,
    required this.themeColor,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(themeColor);
    final foregroundColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(
        currentRouteName: AppRoute.exerciseList.name,
        currentCategoryName: categoryName,
      ),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        title: Text('$categoryName Exercises'),
        actions: const [DrawerBackAction()],
      ),
      body: ValueListenableBuilder<List<CustomExercise>>(
        valueListenable: CustomExerciseStore.exercises,
        builder: (context, customExercises, _) {
          final exercises = _buildExercises(customExercises);

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final totalVolume =
                  exercise.sets * exercise.reps * exercise.weight;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).pushRouteWithArgs(
                      AppRoute.exerciseDetail,
                      ExerciseDetailArgs(
                        exerciseName: exercise.name,
                        muscleGroup: exercise.muscleGroup,
                        sets: exercise.sets,
                        reps: exercise.reps,
                        weight: exercise.weight,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.28),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.14),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: themeColor),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (exercise.isCustom)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Custom',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.muscleGroup,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${exercise.sets} sets | ${exercise.reps} reps | ${_formatWeight(exercise.weight)} kg',
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estimated volume: ${_formatWeight(totalVolume)} kg',
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: themeColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<_ExerciseItem> _buildExercises(List<CustomExercise> customExercises) {
    final baseExercises = List<_ExerciseItem>.from(
      _exerciseLibrary[categoryName] ?? _fallbackExercises,
    );
    final matchingCustomExercises = customExercises
        .where((exercise) => exercise.category == categoryName)
        .map(
          (exercise) => _ExerciseItem(
            name: exercise.name,
            muscleGroup: exercise.muscleGroup,
            sets: exercise.sets,
            reps: exercise.reps,
            weight: exercise.weight,
            isCustom: true,
          ),
        );

    return [...matchingCustomExercises, ...baseExercises];
  }

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

class _ExerciseItem {
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double weight;
  final bool isCustom;

  const _ExerciseItem({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.weight,
    this.isCustom = false,
  });
}

const List<_ExerciseItem> _fallbackExercises = [
  _ExerciseItem(
    name: 'Bodyweight Squat',
    muscleGroup: 'Legs',
    sets: 3,
    reps: 12,
    weight: 0,
  ),
  _ExerciseItem(
    name: 'Push-Up',
    muscleGroup: 'Chest',
    sets: 3,
    reps: 15,
    weight: 0,
  ),
  _ExerciseItem(
    name: 'Mountain Climber',
    muscleGroup: 'Core',
    sets: 4,
    reps: 20,
    weight: 0,
  ),
  _ExerciseItem(
    name: 'Walking Lunge',
    muscleGroup: 'Legs',
    sets: 3,
    reps: 12,
    weight: 8,
  ),
];

const Map<String, List<_ExerciseItem>> _exerciseLibrary = {
  'Strength': [
    _ExerciseItem(
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      sets: 4,
      reps: 8,
      weight: 80,
    ),
    _ExerciseItem(
      name: 'Bench Press',
      muscleGroup: 'Chest',
      sets: 4,
      reps: 10,
      weight: 60,
    ),
    _ExerciseItem(
      name: 'Deadlift',
      muscleGroup: 'Back',
      sets: 4,
      reps: 6,
      weight: 100,
    ),
    _ExerciseItem(
      name: 'Shoulder Press',
      muscleGroup: 'Shoulders',
      sets: 3,
      reps: 10,
      weight: 24,
    ),
  ],
  'HIIT': [
    _ExerciseItem(
      name: 'Burpees',
      muscleGroup: 'Full Body',
      sets: 5,
      reps: 12,
      weight: 0,
    ),
    _ExerciseItem(
      name: 'Kettlebell Swing',
      muscleGroup: 'Posterior Chain',
      sets: 4,
      reps: 20,
      weight: 16,
    ),
    _ExerciseItem(
      name: 'Jump Squat',
      muscleGroup: 'Legs',
      sets: 4,
      reps: 15,
      weight: 0,
    ),
    _ExerciseItem(
      name: 'Battle Rope Slams',
      muscleGroup: 'Arms',
      sets: 6,
      reps: 20,
      weight: 12,
    ),
  ],
  'Cardio': [
    _ExerciseItem(
      name: 'Treadmill Run',
      muscleGroup: 'Legs',
      sets: 1,
      reps: 30,
      weight: 0,
    ),
    _ExerciseItem(
      name: 'Cycling Sprint',
      muscleGroup: 'Legs',
      sets: 6,
      reps: 5,
      weight: 0,
    ),
    _ExerciseItem(
      name: 'Rowing Machine',
      muscleGroup: 'Back',
      sets: 3,
      reps: 12,
      weight: 18,
    ),
    _ExerciseItem(
      name: 'Stair Climber',
      muscleGroup: 'Glutes',
      sets: 4,
      reps: 10,
      weight: 0,
    ),
  ],
  'Flexibility': [
    _ExerciseItem(
      name: 'Hamstring Stretch',
      muscleGroup: 'Hamstrings',
      sets: 3,
      reps: 30,
      weight: 0,
    ),
    _ExerciseItem(
      name: 'Cat-Cow Flow',
      muscleGroup: 'Spine',
      sets: 3,
      reps: 12,
      weight: 0,
    ),
    _ExerciseItem(
      name: 'Hip Flexor Stretch',
      muscleGroup: 'Hips',
      sets: 3,
      reps: 30,
      weight: 0,
    ),
    _ExerciseItem(
      name: 'Child Pose Reach',
      muscleGroup: 'Back',
      sets: 4,
      reps: 20,
      weight: 0,
    ),
  ],
};
