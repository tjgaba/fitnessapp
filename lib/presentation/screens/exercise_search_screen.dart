import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/api_exercise.dart';
import '../../domain/exercise_search_provider.dart';
import '../../domain/routine_provider.dart';
import '../../models/exercise.dart';

class ExerciseSearchScreen extends StatefulWidget {
  const ExerciseSearchScreen({super.key});

  @override
  State<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends State<ExerciseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    context.read<ExerciseSearchProvider>().searchExercises(
      _searchController.text,
    );
  }

  Exercise _mapToRoutineExercise(ApiExercise apiExercise) {
    final normalizedName = apiExercise.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final normalizedMuscle = apiExercise.muscle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final normalizedType = apiExercise.type
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    return Exercise(
      id: 'api_${normalizedType}_${normalizedMuscle}_$normalizedName',
      name: apiExercise.name,
      muscleGroup: apiExercise.muscle,
      sets: 3,
      reps: 10,
      weight: 0,
    );
  }

  void _addToRoutine(ApiExercise apiExercise) {
    final routineExercise = _mapToRoutineExercise(apiExercise);
    context.read<RoutineProvider>().addExercise(routineExercise);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${apiExercise.name} added to routine'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Exercise Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Consumer<ExerciseSearchProvider>(
              builder: (context, provider, _) {
                return TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submitSearch(),
                  decoration: InputDecoration(
                    hintText:
                        'Search by muscle (e.g., biceps, chest, quadriceps)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      tooltip: 'Search exercises',
                      onPressed: provider.isLoading ? null : _submitSearch,
                      icon: const Icon(Icons.search),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ExerciseSearchProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorMessage ?? 'Failed to load exercises.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: provider.retry,
                            child: const Text('Tap to Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.hasResults) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.searchResults.length} exercises found',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: provider.searchResults.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final exercise = provider.searchResults[index];
                              final routineExercise =
                                  _mapToRoutineExercise(exercise);
                              final visual = _ExerciseVisualStyle.fromExercise(
                                exercise,
                              );
                              final isInRoutine = context
                                  .watch<RoutineProvider>()
                                  .isInRoutine(routineExercise.id);
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.blueAccent.withValues(
                                      alpha: 0.16,
                                    ),
                                  ),
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  childrenPadding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  title: Row(
                                    children: [
                                      _ExerciseThumbnail(
                                        style: visual,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 68,
                                    ),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _MetaChip(label: exercise.muscle),
                                        _MetaChip(label: exercise.difficulty),
                                        _MetaChip(label: exercise.type),
                                      ],
                                    ),
                                  ),
                                  children: [
                                    _InfoLine(
                                      label: 'Equipment',
                                      value: exercise.equipments.isEmpty
                                          ? 'None listed'
                                          : exercise.equipments.join(', '),
                                    ),
                                    const SizedBox(height: 12),
                                    _InfoBlock(
                                      title: 'Instructions',
                                      value: exercise.instructions.isEmpty
                                          ? 'No instructions provided.'
                                          : exercise.instructions,
                                    ),
                                    if (exercise.safetyInfo.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      _InfoBlock(
                                        title: 'Safety Info',
                                        value: exercise.safetyInfo,
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: isInRoutine
                                            ? null
                                            : () => _addToRoutine(exercise),
                                        icon: Icon(
                                          isInRoutine
                                              ? Icons.check
                                              : Icons.playlist_add_outlined,
                                        ),
                                        label: Text(
                                          isInRoutine
                                              ? 'Added to Routine'
                                              : 'Add to Routine',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  if (provider.lastQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        'No exercises found for "${provider.lastQuery}". Try a different muscle group.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    );
                  }

                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 44,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Search for exercises by muscle group',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.isEmpty ? 'Unknown' : label,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBlock({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ExerciseThumbnail extends StatelessWidget {
  final _ExerciseVisualStyle style;

  const _ExerciseThumbnail({
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [style.primaryColor, style.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: style.primaryColor.withValues(alpha: 0.24),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              style.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseVisualStyle {
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const _ExerciseVisualStyle({
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory _ExerciseVisualStyle.fromExercise(ApiExercise exercise) {
    final normalizedType = exercise.type.trim().toLowerCase();

    switch (normalizedType) {
      case 'strength':
        return const _ExerciseVisualStyle(
          icon: Icons.fitness_center,
          primaryColor: Color(0xFF2563EB),
          secondaryColor: Color(0xFF60A5FA),
        );
      case 'cardio':
        return const _ExerciseVisualStyle(
          icon: Icons.favorite,
          primaryColor: Color(0xFFEF4444),
          secondaryColor: Color(0xFFFB7185),
        );
      case 'stretching':
      case 'flexibility':
        return const _ExerciseVisualStyle(
          icon: Icons.self_improvement,
          primaryColor: Color(0xFF10B981),
          secondaryColor: Color(0xFF6EE7B7),
        );
      case 'plyometrics':
      case 'hiit':
        return const _ExerciseVisualStyle(
          icon: Icons.bolt,
          primaryColor: Color(0xFFF97316),
          secondaryColor: Color(0xFFFBBF24),
        );
      case 'strongman':
        return const _ExerciseVisualStyle(
          icon: Icons.hardware,
          primaryColor: Color(0xFF7C2D12),
          secondaryColor: Color(0xFFD97706),
        );
      case 'weightlifting':
      case 'olympic_weightlifting':
        return const _ExerciseVisualStyle(
          icon: Icons.sports_gymnastics,
          primaryColor: Color(0xFF7C3AED),
          secondaryColor: Color(0xFFA78BFA),
        );
      default:
        return const _ExerciseVisualStyle(
          icon: Icons.sports_gymnastics,
          primaryColor: Color(0xFF0F766E),
          secondaryColor: Color(0xFF2DD4BF),
        );
    }
  }
}
