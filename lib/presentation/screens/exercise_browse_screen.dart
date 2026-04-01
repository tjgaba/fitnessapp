import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_router.dart';
import '../../data/reference/exercise_category_data.dart';
import '../../data/memory/custom_exercise_store.dart';
import '../../models/custom_exercise.dart';
import '../../models/exercise.dart';
import '../../domain/providers/routine_provider.dart';
import '../widgets/app_drawer.dart';

class ExerciseBrowseScreen extends StatefulWidget {
  const ExerciseBrowseScreen({super.key});

  @override
  State<ExerciseBrowseScreen> createState() => _ExerciseBrowseScreenState();
}

class _ExerciseBrowseScreenState extends State<ExerciseBrowseScreen> {
  final Set<String> _expandedSections = <String>{};

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();

    return ValueListenableBuilder<List<CustomExercise>>(
      valueListenable: CustomExerciseStore.exercises,
      builder: (context, customExercises, _) {
        final sections = _buildCatalogSections(customExercises);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          drawer: AppDrawer(currentRouteName: AppRoute.exerciseBrowse.name),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F7FB),
            foregroundColor: Colors.black87,
            elevation: 0,
            title: const Text('Exercise Browser'),
            actions: const [DrawerBackAction()],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BrowseHeader(
                exerciseCount: routineProvider.exerciseCount,
                customExerciseCount: customExercises.length,
              ),
              const SizedBox(height: 16),
              ...sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _ExerciseCategorySection(
                    section: section,
                    isExpanded: _expandedSections.contains(section.title),
                    onToggleExpanded: () {
                      setState(() {
                        if (_expandedSections.contains(section.title)) {
                          _expandedSections.remove(section.title);
                        } else {
                          _expandedSections.add(section.title);
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                Navigator.of(context).pushRoute(AppRoute.routineSummary),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text('Routine (${routineProvider.exerciseCount})'),
          ),
        );
      },
    );
  }
}

class _BrowseHeader extends StatelessWidget {
  final int exerciseCount;
  final int customExerciseCount;

  const _BrowseHeader({
    required this.exerciseCount,
    required this.customExerciseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6FFFB), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Routine Catalog',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exerciseCount == 0
                ? 'Browse the full exercise inventory across Strength, Cardio, Stretching, Plyometrics, Weightlifting, and Strongman. Your custom exercises are included inside their chosen categories.'
                : '$exerciseCount exercise(s) already in your routine. Tiles update automatically when items are added or removed.',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Custom exercises available: $customExerciseCount',
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseBrowseTile extends StatelessWidget {
  final _CatalogExerciseEntry entry;
  final Color accentColor;

  const _ExerciseBrowseTile({
    required this.entry,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = entry.exercise;
    final isSelected = context.watch<RoutineProvider>().isInRoutine(exercise.id);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isSelected ? 0.62 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.green.withValues(alpha: 0.45)
                : accentColor.withValues(alpha: 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? Colors.green : accentColor).withValues(
                alpha: 0.12,
              ),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (entry.isCustom)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Custom Exercise',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              exercise.muscleGroup,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: '${exercise.sets} sets',
                  accentColor: accentColor,
                ),
                _InfoChip(
                  label: '${exercise.reps} reps',
                  accentColor: accentColor,
                ),
                _InfoChip(
                  label: '${_formatNumber(exercise.weight)} kg',
                  accentColor: accentColor,
                ),
                _InfoChip(
                  label: 'Volume ${_formatNumber(exercise.volume)}',
                  accentColor: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSelected
                    ? null
                    : () {
                        context.read<RoutineProvider>().addExercise(exercise);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: isSelected ? Colors.green : accentColor,
                ),
                icon: Icon(
                  isSelected ? Icons.check : Icons.playlist_add_outlined,
                ),
                label: Text(
                  isSelected ? 'Added to Routine' : 'Add to Routine',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _InfoChip({
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExerciseCategorySection extends StatelessWidget {
  final _ExerciseCategorySectionData section;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const _ExerciseCategorySection({
    required this.section,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: section.color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: section.color.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(section.icon, color: section.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onToggleExpanded,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: section.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: section.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Minimize' : 'Expand',
                          style: TextStyle(
                            color: section.color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: section.color,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!isExpanded)
            Text(
              '${section.exercises.length} exercise(s) hidden. Expand to view the full ${section.title.toLowerCase()} catalog.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            )
          else
            ...section.exercises.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExerciseBrowseTile(
                  entry: entry,
                  accentColor: section.color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}

class _ExerciseCategorySectionData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<_CatalogExerciseEntry> exercises;

  const _ExerciseCategorySectionData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.exercises,
  });
}

class _CatalogExerciseEntry {
  final Exercise exercise;
  final bool isCustom;

  const _CatalogExerciseEntry({
    required this.exercise,
    this.isCustom = false,
  });
}

List<_ExerciseCategorySectionData> _buildCatalogSections(
  List<CustomExercise> customExercises,
) {
  return _baseCatalogSections.map((section) {
    final customEntries = customExercises
        .where((exercise) => categoryMatches(section.title, exercise.category))
        .map(
          (exercise) => _CatalogExerciseEntry(
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
        )
        .toList();

    return _ExerciseCategorySectionData(
      title: section.title,
      description: section.description,
      icon: section.icon,
      color: section.color,
      exercises: [...customEntries, ...section.exercises],
    );
  }).toList();
}

const List<_ExerciseCategorySectionData> _baseCatalogSections = [
  _ExerciseCategorySectionData(
    title: 'Strength',
    description: 'Heavy compound and accessory lifts for muscular strength.',
    icon: Icons.fitness_center,
    color: Colors.blueAccent,
    exercises: [
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'strength_barbell_squat_01',
          name: 'Barbell Squat',
          muscleGroup: 'Legs',
          sets: 4,
          reps: 8,
          weight: 80,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'strength_bench_press_01',
          name: 'Bench Press',
          muscleGroup: 'Chest',
          sets: 4,
          reps: 10,
          weight: 60,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'strength_deadlift_01',
          name: 'Deadlift',
          muscleGroup: 'Back',
          sets: 4,
          reps: 6,
          weight: 100,
        ),
      ),
      _CatalogExerciseEntry(
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
  ),
  _ExerciseCategorySectionData(
    title: 'Plyometrics',
    description: 'Explosive intervals that keep rest short and intensity high.',
    icon: Icons.flash_on,
    color: Colors.orangeAccent,
    exercises: [
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'hiit_burpee_01',
          name: 'Burpees',
          muscleGroup: 'Full Body',
          sets: 5,
          reps: 12,
          weight: 0,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'hiit_kettlebell_swing_01',
          name: 'Kettlebell Swing',
          muscleGroup: 'Posterior Chain',
          sets: 4,
          reps: 20,
          weight: 16,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'hiit_jump_squat_01',
          name: 'Jump Squat',
          muscleGroup: 'Legs',
          sets: 4,
          reps: 15,
          weight: 0,
        ),
      ),
      _CatalogExerciseEntry(
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
  ),
  _ExerciseCategorySectionData(
    title: 'Cardio',
    description: 'Conditioning-focused work that builds endurance and engine.',
    icon: Icons.directions_run,
    color: Colors.pinkAccent,
    exercises: [
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'cardio_treadmill_run_01',
          name: 'Treadmill Run',
          muscleGroup: 'Legs',
          sets: 1,
          reps: 30,
          weight: 0,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'cardio_cycling_sprint_01',
          name: 'Cycling Sprint',
          muscleGroup: 'Legs',
          sets: 6,
          reps: 5,
          weight: 0,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'cardio_rowing_machine_01',
          name: 'Rowing Machine',
          muscleGroup: 'Back',
          sets: 3,
          reps: 12,
          weight: 18,
        ),
      ),
      _CatalogExerciseEntry(
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
  ),
  _ExerciseCategorySectionData(
    title: 'Stretching',
    description: 'Mobility and stretch work to improve range of motion.',
    icon: Icons.self_improvement,
    color: Colors.green,
    exercises: [
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'flexibility_hamstring_stretch_01',
          name: 'Hamstring Stretch',
          muscleGroup: 'Hamstrings',
          sets: 3,
          reps: 30,
          weight: 0,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'flexibility_cat_cow_flow_01',
          name: 'Cat-Cow Flow',
          muscleGroup: 'Spine',
          sets: 3,
          reps: 12,
          weight: 0,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'flexibility_hip_flexor_stretch_01',
          name: 'Hip Flexor Stretch',
          muscleGroup: 'Hips',
          sets: 3,
          reps: 30,
          weight: 0,
        ),
      ),
      _CatalogExerciseEntry(
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
  ),
  _ExerciseCategorySectionData(
    title: 'Weightlifting',
    description: 'Olympic-style lifts focused on speed, timing, and power.',
    icon: Icons.sports_gymnastics,
    color: Colors.deepPurpleAccent,
    exercises: [
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'weightlifting_power_clean_01',
          name: 'Power Clean',
          muscleGroup: 'Full Body',
          sets: 5,
          reps: 3,
          weight: 70,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'weightlifting_hang_snatch_01',
          name: 'Hang Snatch',
          muscleGroup: 'Shoulders',
          sets: 4,
          reps: 3,
          weight: 45,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'weightlifting_push_jerk_01',
          name: 'Push Jerk',
          muscleGroup: 'Shoulders',
          sets: 5,
          reps: 2,
          weight: 60,
        ),
      ),
      _CatalogExerciseEntry(
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
  ),
  _ExerciseCategorySectionData(
    title: 'Strongman',
    description: 'Carries, loads, and awkward-object work for brute strength.',
    icon: Icons.hardware,
    color: Colors.brown,
    exercises: [
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'strongman_farmers_carry_01',
          name: "Farmer's Carry",
          muscleGroup: 'Forearms',
          sets: 4,
          reps: 30,
          weight: 40,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'strongman_atlas_stone_load_01',
          name: 'Atlas Stone Load',
          muscleGroup: 'Lower Back',
          sets: 5,
          reps: 4,
          weight: 75,
        ),
      ),
      _CatalogExerciseEntry(
        exercise: Exercise(
          id: 'strongman_yoke_walk_01',
          name: 'Yoke Walk',
          muscleGroup: 'Full Body',
          sets: 4,
          reps: 20,
          weight: 140,
        ),
      ),
      _CatalogExerciseEntry(
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
  ),
];


