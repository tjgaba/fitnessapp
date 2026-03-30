import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_router.dart';
import '../../data/custom_exercise_store.dart';
import '../../models/custom_exercise.dart';
import '../../models/exercise.dart';
import '../../domain/routine_provider.dart';
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
    final routineProvider = context.watch<RoutineProvider>();

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
              final entry = exercises[index];
              final exercise = entry.exercise;
              final isInRoutine = routineProvider.isInRoutine(exercise.id);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).pushRouteWithArgs(
                      AppRoute.exerciseDetail,
                      ExerciseDetailArgs(
                        exercise: exercise,
                        accentColor: themeColor,
                      ),
                    );
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: isInRoutine ? 0.68 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isInRoutine
                            ? Colors.green.withValues(alpha: 0.4)
                            : themeColor.withValues(alpha: 0.28),
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
                                    if (entry.isCustom)
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
                                  'Estimated volume: ${_formatWeight(exercise.volume)} kg',
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              IconButton(
                                tooltip: isInRoutine
                                    ? 'Remove from routine'
                                    : 'Add to routine',
                                onPressed: () {
                                  if (isInRoutine) {
                                    context
                                        .read<RoutineProvider>()
                                        .removeExercise(exercise.id);
                                  } else {
                                    context
                                        .read<RoutineProvider>()
                                        .addExercise(exercise);
                                  }
                                },
                                icon: Icon(
                                  isInRoutine
                                      ? Icons.check_circle
                                      : Icons.playlist_add_circle_outlined,
                                  color: isInRoutine
                                      ? Colors.green
                                      : themeColor,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: themeColor,
                              ),
                            ],
                          ),
                        ],
                      ),
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
            exercise: Exercise(
              id: exercise.id,
              name: exercise.name,
              muscleGroup: exercise.muscleGroup,
              sets: exercise.sets,
              reps: exercise.reps,
              weight: exercise.weight,
            ),
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
  final Exercise exercise;
  final bool isCustom;

  const _ExerciseItem({
    required this.exercise,
    this.isCustom = false,
  });
}

const List<_ExerciseItem> _fallbackExercises = [
  _ExerciseItem(
    exercise: Exercise(
      id: 'fallback_bodyweight_squat_01',
      name: 'Bodyweight Squat',
      muscleGroup: 'Legs',
      sets: 3,
      reps: 12,
      weight: 0,
    ),
  ),
  _ExerciseItem(
    exercise: Exercise(
      id: 'fallback_push_up_01',
      name: 'Push-Up',
      muscleGroup: 'Chest',
      sets: 3,
      reps: 15,
      weight: 0,
    ),
  ),
  _ExerciseItem(
    exercise: Exercise(
      id: 'fallback_mountain_climber_01',
      name: 'Mountain Climber',
      muscleGroup: 'Core',
      sets: 4,
      reps: 20,
      weight: 0,
    ),
  ),
  _ExerciseItem(
    exercise: Exercise(
      id: 'fallback_walking_lunge_01',
      name: 'Walking Lunge',
      muscleGroup: 'Legs',
      sets: 3,
      reps: 12,
      weight: 8,
    ),
  ),
];

const Map<String, List<_ExerciseItem>> _exerciseLibrary = {
  'Strength': [
    _ExerciseItem(
      exercise: Exercise(
        id: 'strength_barbell_squat_01',
        name: 'Barbell Squat',
        muscleGroup: 'Legs',
        sets: 4,
        reps: 8,
        weight: 80,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'strength_bench_press_01',
        name: 'Bench Press',
        muscleGroup: 'Chest',
        sets: 4,
        reps: 10,
        weight: 60,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'strength_deadlift_01',
        name: 'Deadlift',
        muscleGroup: 'Back',
        sets: 4,
        reps: 6,
        weight: 100,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'strength_shoulder_press_01',
        name: 'Shoulder Press',
        muscleGroup: 'Shoulders',
        sets: 3,
        reps: 10,
        weight: 24,
      ),
    ),
  ],
  'HIIT': [
    _ExerciseItem(
      exercise: Exercise(
        id: 'hiit_burpee_01',
        name: 'Burpees',
        muscleGroup: 'Full Body',
        sets: 5,
        reps: 12,
        weight: 0,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'hiit_kettlebell_swing_01',
        name: 'Kettlebell Swing',
        muscleGroup: 'Posterior Chain',
        sets: 4,
        reps: 20,
        weight: 16,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'hiit_jump_squat_01',
        name: 'Jump Squat',
        muscleGroup: 'Legs',
        sets: 4,
        reps: 15,
        weight: 0,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'hiit_battle_rope_slams_01',
        name: 'Battle Rope Slams',
        muscleGroup: 'Arms',
        sets: 6,
        reps: 20,
        weight: 12,
      ),
    ),
  ],
  'Cardio': [
    _ExerciseItem(
      exercise: Exercise(
        id: 'cardio_treadmill_run_01',
        name: 'Treadmill Run',
        muscleGroup: 'Legs',
        sets: 1,
        reps: 30,
        weight: 0,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'cardio_cycling_sprint_01',
        name: 'Cycling Sprint',
        muscleGroup: 'Legs',
        sets: 6,
        reps: 5,
        weight: 0,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'cardio_rowing_machine_01',
        name: 'Rowing Machine',
        muscleGroup: 'Back',
        sets: 3,
        reps: 12,
        weight: 18,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'cardio_stair_climber_01',
        name: 'Stair Climber',
        muscleGroup: 'Glutes',
        sets: 4,
        reps: 10,
        weight: 0,
      ),
    ),
  ],
  'Flexibility': [
    _ExerciseItem(
      exercise: Exercise(
        id: 'flexibility_hamstring_stretch_01',
        name: 'Hamstring Stretch',
        muscleGroup: 'Hamstrings',
        sets: 3,
        reps: 30,
        weight: 0,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'flexibility_cat_cow_flow_01',
        name: 'Cat-Cow Flow',
        muscleGroup: 'Spine',
        sets: 3,
        reps: 12,
        weight: 0,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'flexibility_hip_flexor_stretch_01',
        name: 'Hip Flexor Stretch',
        muscleGroup: 'Hips',
        sets: 3,
        reps: 30,
        weight: 0,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'flexibility_child_pose_reach_01',
        name: 'Child Pose Reach',
        muscleGroup: 'Back',
        sets: 4,
        reps: 20,
        weight: 0,
      ),
    ),
  ],
  'Weightlifting': [
    _ExerciseItem(
      exercise: Exercise(
        id: 'weightlifting_power_clean_01',
        name: 'Power Clean',
        muscleGroup: 'Full Body',
        sets: 5,
        reps: 3,
        weight: 70,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'weightlifting_hang_snatch_01',
        name: 'Hang Snatch',
        muscleGroup: 'Shoulders',
        sets: 4,
        reps: 3,
        weight: 45,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'weightlifting_push_jerk_01',
        name: 'Push Jerk',
        muscleGroup: 'Shoulders',
        sets: 5,
        reps: 2,
        weight: 60,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'weightlifting_front_squat_01',
        name: 'Front Squat',
        muscleGroup: 'Quadriceps',
        sets: 4,
        reps: 5,
        weight: 85,
      ),
    ),
  ],
  'Strongman': [
    _ExerciseItem(
      exercise: Exercise(
        id: 'strongman_farmers_carry_01',
        name: "Farmer's Carry",
        muscleGroup: 'Forearms',
        sets: 4,
        reps: 30,
        weight: 40,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'strongman_atlas_stone_load_01',
        name: 'Atlas Stone Load',
        muscleGroup: 'Lower Back',
        sets: 5,
        reps: 4,
        weight: 75,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'strongman_yoke_walk_01',
        name: 'Yoke Walk',
        muscleGroup: 'Full Body',
        sets: 4,
        reps: 20,
        weight: 140,
      ),
    ),
    _ExerciseItem(
      exercise: Exercise(
        id: 'strongman_log_press_01',
        name: 'Log Press',
        muscleGroup: 'Shoulders',
        sets: 4,
        reps: 6,
        weight: 55,
      ),
    ),
  ],
};


