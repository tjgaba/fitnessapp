import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_router.dart';
import '../../models/exercise.dart';
import '../../domain/routine_provider.dart';
import '../widgets/app_drawer.dart';

class RoutineSummaryScreen extends StatefulWidget {
  const RoutineSummaryScreen({super.key});

  @override
  State<RoutineSummaryScreen> createState() => _RoutineSummaryScreenState();
}

class _RoutineSummaryScreenState extends State<RoutineSummaryScreen> {
  final Set<String> _expandedGroups = <String>{};

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();
    final routine = routineProvider.routine;
    final groupedRoutine = _groupExercisesByMuscleGroup(routine);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(currentRouteName: AppRoute.routineSummary.name),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Routine Summary'),
        actions: [
          if (routine.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearRoutine(context),
              child: const Text('Clear Routine'),
            ),
          const DrawerBackAction(),
        ],
      ),
      body: routine.isEmpty
          ? const _EmptyRoutineState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RoutineStats(provider: routineProvider),
                const SizedBox(height: 16),
                ...groupedRoutine.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RoutineExerciseGroup(
                      muscleGroup: entry.key,
                      exercises: entry.value,
                      isExpanded: _expandedGroups.contains(entry.key),
                      onToggle: () {
                        setState(() {
                          if (_expandedGroups.contains(entry.key)) {
                            _expandedGroups.remove(entry.key);
                          } else {
                            _expandedGroups.add(entry.key);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmClearRoutine(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear routine?'),
          content: const Text(
            'This removes every selected exercise from the current routine.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true && context.mounted) {
      context.read<RoutineProvider>().clearRoutine();
    }
  }
}

class _RoutineStats extends StatelessWidget {
  final RoutineProvider provider;

  const _RoutineStats({required this.provider});

  @override
  Widget build(BuildContext context) {
    final breakdownEntries = provider.muscleGroupBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final highestCount = breakdownEntries.isEmpty
        ? 1
        : breakdownEntries.first.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Routine Totals',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(
                label: 'Exercises',
                value: '${provider.exerciseCount}',
              ),
              _StatChip(
                label: 'Completed',
                value: '${provider.completedExerciseCount}',
              ),
              _StatChip(
                label: 'Sets',
                value: '${provider.totalSets}',
              ),
              _StatChip(
                label: 'Volume',
                value: '${_formatNumber(provider.totalVolume)} kg',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Routine Completion',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(provider.completionProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.indigo,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: provider.completionProgress,
              minHeight: 10,
              backgroundColor: Colors.indigo.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.hasRoutine
                ? '${provider.completedExerciseCount} of ${provider.exerciseCount} exercises checked complete.'
                : 'Add exercises to start tracking routine completion.',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Muscle Group Breakdown',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...breakdownEntries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BreakdownBar(
                label: entry.key,
                count: entry.value,
                fraction: entry.value / highestCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineExerciseGroup extends StatelessWidget {
  final String muscleGroup;
  final List<Exercise> exercises;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _RoutineExerciseGroup({
    required this.muscleGroup,
    required this.exercises,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.08),
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
                  color: Colors.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.indigo,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      muscleGroup,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercises.length} exercise(s) in this group',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.indigo.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Minimize' : 'Expand',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.indigo,
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
              '${exercises.length} exercise(s) hidden. Expand to view this $muscleGroup section.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            )
          else
            ...exercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RoutineExerciseTile(exercise: exercise),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoutineExerciseTile extends StatelessWidget {
  final Exercise exercise;

  const _RoutineExerciseTile({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();
    final isCompleted = routineProvider.isExerciseCompleted(exercise.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF3FFF7) : const Color(0xFFF9FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.26)
              : Colors.indigo.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isCompleted,
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (value) {
                  routineProvider.toggleExerciseCompleted(
                    exercise.id,
                    value ?? false,
                  );
                },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted ? 'Marked complete' : 'Mark this exercise complete',
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.black45,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isCompleted ? 'Mark incomplete' : 'Mark complete',
                onPressed: () {
                  routineProvider.toggleExerciseCompleted(
                    exercise.id,
                    !isCompleted,
                  );
                },
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.indigo,
                ),
              ),
              IconButton(
                tooltip: 'Remove exercise',
                onPressed: () {
                  context.read<RoutineProvider>().removeExercise(exercise.id);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${exercise.sets} x ${exercise.reps} x ${_formatNumber(exercise.weight)} kg',
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.indigo,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Volume: ${_formatNumber(exercise.volume)} kg',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  final String label;
  final int count;
  final double fraction;

  const _BreakdownBar({
    required this.label,
    required this.count,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.indigo,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: fraction.clamp(0, 1),
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
          ),
        ),
      ],
    );
  }
}

class _EmptyRoutineState extends StatelessWidget {
  const _EmptyRoutineState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.indigo.withValues(alpha: 0.16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.playlist_remove_outlined,
                  color: Colors.indigo,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your routine is empty',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Browse the exercise catalog and add movements to start building a structured workout routine.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushRoute(AppRoute.exerciseBrowse),
                icon: const Icon(Icons.search),
                label: const Text('Browse Exercises'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.bold,
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

Map<String, List<Exercise>> _groupExercisesByMuscleGroup(List<Exercise> routine) {
  final grouped = <String, List<Exercise>>{};

  for (final exercise in routine) {
    grouped.putIfAbsent(exercise.muscleGroup, () => <Exercise>[]).add(exercise);
  }

  final sortedEntries = grouped.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return Map<String, List<Exercise>>.fromEntries(sortedEntries);
}


