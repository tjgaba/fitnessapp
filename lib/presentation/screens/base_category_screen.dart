import 'package:flutter/material.dart';

import '../../data/category_session_store.dart';
import '../../data/custom_exercise_store.dart';
import '../../models/category_session.dart';
import '../../models/custom_exercise.dart';
import '../../models/workout_category.dart';
import '../widgets/category_banner.dart';

class BaseCategoryScreen extends StatefulWidget {
  final WorkoutCategory category;

  const BaseCategoryScreen({super.key, required this.category});

  @override
  State<BaseCategoryScreen> createState() => _BaseCategoryScreenState();
}

class _BaseCategoryScreenState extends State<BaseCategoryScreen> {
  final Set<String> _selectedExerciseIds = <String>{};
  bool _isCustomExerciseSectionExpanded = false;

  @override
  void initState() {
    super.initState();
    CategorySessionStore.ensureCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final color = category.color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Icon(category.icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              category.title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<Map<String, List<CategorySession>>>(
              valueListenable: CategorySessionStore.sessionsByCategory,
              builder: (context, _, __) {
                final sessions = CategorySessionStore.sessionsFor(category.title);
                final completedCount =
                    sessions.where((session) => session.completed).length;

                return CategoryBanner(
                  category: category,
                  sessionsCompleted: completedCount,
                  sessionsGoalPerWeek: sessions.length,
                );
              },
            ),
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _description(category.title),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _sectionTitle('This Week\'s Sessions', color),
            const SizedBox(height: 10),
            ValueListenableBuilder<Map<String, List<CategorySession>>>(
              valueListenable: CategorySessionStore.sessionsByCategory,
              builder: (context, _, __) {
                final sessions = CategorySessionStore.sessionsFor(category.title);
                final exerciseLookup = {
                  for (final exercise in CustomExerciseStore.exercises.value)
                    exercise.id: exercise,
                };

                return Column(
                  children: sessions
                      .map(
                        (session) => _SessionRow(
                          session: session,
                          color: color,
                          title: category.title,
                          exerciseSummary: session.exerciseIds.isEmpty
                              ? 'No custom exercises added'
                              : session.exerciseIds
                                  .map((id) => exerciseLookup[id]?.name ?? 'Exercise')
                                  .join(', '),
                          onToggleComplete: () =>
                              CategorySessionStore.toggleSessionCompletion(
                            category.title,
                            session.index,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _sectionTitle('Custom Exercises', color)),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _isCustomExerciseSectionExpanded =
                            !_isCustomExerciseSectionExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isCustomExerciseSectionExpanded
                                ? 'Minimize'
                                : 'Expand',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _isCustomExerciseSectionExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: color,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<List<CustomExercise>>(
              valueListenable: CustomExerciseStore.exercises,
              builder: (context, exercises, _) {
                final matchingExercises = exercises
                    .where((exercise) => exercise.category == category.title)
                    .toList();

                if (!_isCustomExerciseSectionExpanded) {
                  return Text(
                    matchingExercises.isEmpty
                        ? 'Section minimized. No custom exercises saved yet.'
                        : 'Section minimized. ${matchingExercises.length} custom exercise(s) available.',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  );
                }

                if (matchingExercises.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      'No custom exercises added under ${category.title} yet.',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    ...matchingExercises
                        .map(
                          (exercise) => _CustomExerciseRow(
                            exercise: exercise,
                            color: color,
                            selected:
                                _selectedExerciseIds.contains(exercise.id),
                            onToggleSelection: () {
                              setState(() {
                                if (_selectedExerciseIds.contains(exercise.id)) {
                                  _selectedExerciseIds.remove(exercise.id);
                                } else {
                                  _selectedExerciseIds.add(exercise.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 12),
                    _GlowButton(
                      label: 'ADD TO SESSION',
                      color: color,
                      onTap: () => _addSelectedExercisesToSession(context),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _GlowButton(
              label: 'START WORKOUT',
              color: color,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${category.title} workout coming soon!'),
                    backgroundColor: color.withValues(alpha: 0.85),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _addSelectedExercisesToSession(BuildContext context) {
    final category = widget.category;
    final color = category.color;

    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Select at least one exercise first.'),
          backgroundColor: color.withValues(alpha: 0.85),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final added = CategorySessionStore.addExercisesToNextSession(
      category.title,
      _selectedExerciseIds.toList(),
    );

    if (added) {
      setState(() => _selectedExerciseIds.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exercises added to the next ${category.title} session.',
          ),
          backgroundColor: color.withValues(alpha: 0.85),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All sessions already have assigned exercises.'),
        backgroundColor: color.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _description(String title) {
    switch (title) {
      case 'HIIT':
        return 'High-intensity interval training burns maximum calories in short bursts of effort.';
      case 'Strength':
        return 'Resistance training builds muscle mass and increases your resting metabolic rate.';
      case 'Cardio':
        return 'Steady-state cardio improves cardiovascular health and builds endurance over time.';
      case 'Flexibility':
        return 'Stretching and mobility work improve range of motion, posture, and recovery speed.';
      default:
        return '';
    }
  }

  Widget _sectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _CustomExerciseRow extends StatelessWidget {
  final CustomExercise exercise;
  final Color color;
  final bool selected;
  final VoidCallback onToggleSelection;

  const _CustomExerciseRow({
    required this.exercise,
    required this.color,
    required this.selected,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? color.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: selected ? 0.18 : 0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            activeColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (_) => onToggleSelection(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.sets} sets | ${exercise.reps} reps | ${_formatNumber(exercise.weight)} kg | ${exercise.intensity}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercise.muscleGroup} | Volume ${_formatNumber(exercise.totalVolume)} kg',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

class _SessionRow extends StatelessWidget {
  final CategorySession session;
  final Color color;
  final String title;
  final String exerciseSummary;
  final VoidCallback onToggleComplete;

  const _SessionRow({
    required this.session,
    required this.color,
    required this.title,
    required this.exerciseSummary,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: session.completed
              ? color.withValues(alpha: 0.45)
              : Colors.black12,
          width: 1,
        ),
        boxShadow: session.completed
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Checkbox(
            value: session.completed,
            activeColor: color,
            onChanged: (_) => onToggleComplete(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title - Session ${session.index}',
                  style: TextStyle(
                    color: session.completed ? Colors.black87 : Colors.black45,
                    fontSize: 13,
                    fontWeight:
                        session.completed ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  exerciseSummary,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!session.completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: 0.45),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                'Pending',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlowButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GlowButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => _pressed = true);
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() => _pressed = false);
            }
          });
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _pressed ? 0.55 : 0.28),
                blurRadius: _pressed ? 20 : 10,
              ),
            ],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}


