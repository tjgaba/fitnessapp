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
                                  title: Text(
                                    exercise.name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
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
