import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_router.dart';
import '../../models/exercise.dart';
import '../../domain/routine_provider.dart';
import '../widgets/app_drawer.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final Color accentColor;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isInRoutine = context.watch<RoutineProvider>().isInRoutine(exercise.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(
        currentRouteName: AppRoute.exerciseDetail.name,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(exercise.name),
        actions: const [DrawerBackAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exercise Overview',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${exercise.name} targets ${exercise.muscleGroup} with a structured working set.',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _DetailCard(
            accentColor: accentColor,
            child: Column(
              children: [
                _DetailRow(label: 'Exercise Name', value: exercise.name),
                const SizedBox(height: 12),
                _DetailRow(label: 'Muscle Group', value: exercise.muscleGroup),
                const SizedBox(height: 12),
                _DetailRow(label: 'Sets', value: '${exercise.sets}'),
                const SizedBox(height: 12),
                _DetailRow(label: 'Reps', value: '${exercise.reps}'),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Weight',
                  value: '${_formatWeight(exercise.weight)} kg',
                ),
                if (exercise.equipments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Equipment',
                    value: exercise.equipments.join(', '),
                  ),
                ],
              ],
            ),
          ),
          if (exercise.instructions.isNotEmpty) ...[
            const SizedBox(height: 18),
            _DetailCard(
              accentColor: accentColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exercise.instructions,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (exercise.safetyInfo.isNotEmpty) ...[
            const SizedBox(height: 18),
            _DetailCard(
              accentColor: accentColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety Info',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exercise.safetyInfo,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          _DetailCard(
            accentColor: accentColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Volume',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${exercise.sets} x ${exercise.reps} x ${_formatWeight(exercise.weight)} = ${_formatWeight(exercise.volume)} kg',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Training volume helps you compare workload across sessions and track progression over time.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (isInRoutine) {
                  context.read<RoutineProvider>().removeExercise(exercise.id);
                } else {
                  context.read<RoutineProvider>().addExercise(exercise);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: isInRoutine ? Colors.green : accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Icon(
                isInRoutine ? Icons.check_circle : Icons.playlist_add_circle,
              ),
              label: Text(
                isInRoutine ? 'Remove From Routine' : 'Add To Routine',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const _DetailCard({
    required this.child,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


