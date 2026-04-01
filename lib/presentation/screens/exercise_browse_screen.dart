import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/memory/custom_exercise_store.dart';
import '../../data/models/api_exercise.dart';
import '../../data/reference/exercise_category_data.dart';
import '../../data/repositories/exercise_api_repository.dart';
import '../../domain/providers/routine_provider.dart';
import '../../models/custom_exercise.dart';
import '../../models/exercise.dart';
import '../../models/workout_category.dart';
import '../navigation/app_router.dart';
import '../widgets/app_drawer.dart';

class ExerciseBrowseScreen extends StatefulWidget {
  const ExerciseBrowseScreen({super.key});

  @override
  State<ExerciseBrowseScreen> createState() => _ExerciseBrowseScreenState();
}

class _ExerciseBrowseScreenState extends State<ExerciseBrowseScreen> {
  final Set<String> _expandedSections = <String>{};
  late Future<List<_ExerciseCategorySectionData>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = _loadSections();
  }

  Future<List<_ExerciseCategorySectionData>> _loadSections() async {
    final repository = context.read<ExerciseApiRepository>();

    final results = await Future.wait(
      exerciseCategoryDefinitions.map((definition) async {
        try {
          final apiExercises = await repository.searchExercises(
            type: definition.apiType,
          );
          return _CategoryLoadResult(
            definition: definition,
            apiExercises: apiExercises,
          );
        } catch (error) {
          return _CategoryLoadResult(
            definition: definition,
            errorMessage: error.toString().replaceFirst('Exception: ', ''),
          );
        }
      }),
    );

    return results.map(_buildApiSection).toList();
  }

  _ExerciseCategorySectionData _buildApiSection(_CategoryLoadResult result) {
    return _ExerciseCategorySectionData(
      title: result.definition.category.title,
      description: _sectionDescription(result.definition.category),
      icon: result.definition.category.icon,
      color: result.definition.category.color,
      exercises: result.apiExercises.map(_mapApiExercise).toList(),
      errorMessage: result.errorMessage,
    );
  }

  _CatalogExerciseEntry _mapApiExercise(ApiExercise apiExercise) {
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

    return _CatalogExerciseEntry(
      exercise: Exercise(
        id: 'api_${normalizedType}_${normalizedMuscle}_$normalizedName',
        name: apiExercise.name,
        muscleGroup: apiExercise.muscle.isEmpty ? 'Unknown' : apiExercise.muscle,
        sets: _estimatedSets(apiExercise.difficulty),
        reps: _estimatedReps(apiExercise.type),
        weight: 0,
        instructions: apiExercise.instructions,
        safetyInfo: apiExercise.safetyInfo,
        equipments: apiExercise.equipments,
      ),
      sourceLabel: 'API',
      supportingText: _buildSupportingText(apiExercise),
    );
  }

  int _estimatedSets(String difficulty) {
    switch (difficulty.trim().toLowerCase()) {
      case 'beginner':
        return 2;
      case 'expert':
        return 4;
      default:
        return 3;
    }
  }

  int _estimatedReps(String type) {
    switch (type.trim().toLowerCase()) {
      case 'cardio':
      case 'stretching':
        return 12;
      case 'strongman':
      case 'weightlifting':
        return 6;
      default:
        return 10;
    }
  }

  String _buildSupportingText(ApiExercise apiExercise) {
    final details = <String>[];
    if (apiExercise.difficulty.isNotEmpty) {
      details.add(_formatLabel(apiExercise.difficulty));
    }
    if (apiExercise.equipments.isNotEmpty) {
      details.add(apiExercise.equipments.first);
    }
    return details.join(' | ');
  }

  String _formatLabel(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value
        .split('_')
        .map(
          (segment) => segment.isEmpty
              ? segment
              : '${segment[0].toUpperCase()}${segment.substring(1)}',
        )
        .join(' ');
  }

  String _sectionDescription(WorkoutCategory category) {
    return '${category.intensity} intensity · ${category.sessionsGoalPerWeek} session goal per week';
  }

  void _reloadSections() {
    setState(() {
      _sectionsFuture = _loadSections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routineProvider = context.watch<RoutineProvider>();

    return ValueListenableBuilder<List<CustomExercise>>(
      valueListenable: CustomExerciseStore.exercises,
      builder: (context, customExercises, _) {
        return FutureBuilder<List<_ExerciseCategorySectionData>>(
          future: _sectionsFuture,
          builder: (context, snapshot) {
            final apiSections = snapshot.data ?? const <_ExerciseCategorySectionData>[];
            final sections = _mergeCatalogSections(apiSections, customExercises);
            final apiExerciseCount = apiSections.fold<int>(
              0,
              (sum, section) => sum + section.exercises.length,
            );

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
              body: _buildBody(
                snapshot: snapshot,
                sections: sections,
                customExercises: customExercises,
                exerciseCount: routineProvider.exerciseCount,
                apiExerciseCount: apiExerciseCount,
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
      },
    );
  }

  Widget _buildBody({
    required AsyncSnapshot<List<_ExerciseCategorySectionData>> snapshot,
    required List<_ExerciseCategorySectionData> sections,
    required List<CustomExercise> customExercises,
    required int exerciseCount,
    required int apiExerciseCount,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting && sections.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError && sections.isEmpty) {
      return _BrowseLoadFailure(onRetry: _reloadSections);
    }

    final hasAnySectionError = sections.any((section) => section.hasError);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BrowseHeader(
          exerciseCount: exerciseCount,
          customExerciseCount: customExercises.length,
          apiExerciseCount: apiExerciseCount,
        ),
        if (hasAnySectionError) ...[
          const SizedBox(height: 14),
          _CatalogWarningBanner(onRetry: _reloadSections),
        ],
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
    );
  }
}

class _BrowseHeader extends StatelessWidget {
  final int exerciseCount;
  final int customExerciseCount;
  final int apiExerciseCount;

  const _BrowseHeader({
    required this.exerciseCount,
    required this.customExerciseCount,
    required this.apiExerciseCount,
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
                ? 'Browse live API exercises by category. Your custom exercises are merged into the matching sections.'
                : '$exerciseCount exercise(s) already in your routine. Tiles update automatically when items are added or removed.',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Live API exercises loaded: $apiExerciseCount',
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
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
            if (entry.sourceLabel != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (entry.isCustom ? Colors.green : accentColor).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.sourceLabel!,
                  style: TextStyle(
                    color: entry.isCustom ? Colors.green : accentColor,
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
            if (entry.supportingText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                entry.supportingText,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
          if (section.hasError)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Live data unavailable for ${section.title}: ${section.errorMessage}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          if (!isExpanded)
            Text(
              '${section.exercises.length} exercise(s) hidden. Expand to view the full ${section.title.toLowerCase()} catalog.',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            )
          else if (section.exercises.isEmpty)
            Text(
              section.hasError
                  ? 'No exercises to show for this section right now.'
                  : 'No exercises returned for this category.',
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

class _CatalogWarningBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const _CatalogWarningBanner({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.orange),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Some categories could not be refreshed from the API. Retry to request live data again.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _BrowseLoadFailure extends StatelessWidget {
  final VoidCallback onRetry;

  const _BrowseLoadFailure({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Failed to load the exercise catalog.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The browser now depends on live API data. Check your connection and retry.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
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
  final String? errorMessage;

  const _ExerciseCategorySectionData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.exercises,
    this.errorMessage,
  });

  bool get hasError => (errorMessage ?? '').isNotEmpty;
}

class _CatalogExerciseEntry {
  final Exercise exercise;
  final bool isCustom;
  final String? sourceLabel;
  final String supportingText;

  const _CatalogExerciseEntry({
    required this.exercise,
    this.isCustom = false,
    this.sourceLabel,
    this.supportingText = '',
  });
}

class _CategoryLoadResult {
  final ExerciseCategoryDefinition definition;
  final List<ApiExercise> apiExercises;
  final String? errorMessage;

  const _CategoryLoadResult({
    required this.definition,
    this.apiExercises = const <ApiExercise>[],
    this.errorMessage,
  });
}

List<_ExerciseCategorySectionData> _mergeCatalogSections(
  List<_ExerciseCategorySectionData> apiSections,
  List<CustomExercise> customExercises,
) {
  if (apiSections.isEmpty) {
    return exerciseCategoryDefinitions.map((definition) {
      final customEntries = customExercises
          .where(
            (exercise) => categoryMatches(
              definition.category.title,
              exercise.category,
            ),
          )
          .map(_mapCustomExercise)
          .toList();

      return _ExerciseCategorySectionData(
        title: definition.category.title,
        description:
            '${definition.category.intensity} intensity · ${definition.category.sessionsGoalPerWeek} session goal per week',
        icon: definition.category.icon,
        color: definition.category.color,
        exercises: customEntries,
      );
    }).toList();
  }

  return apiSections.map((section) {
    final customEntries = customExercises
        .where((exercise) => categoryMatches(section.title, exercise.category))
        .map(_mapCustomExercise)
        .toList();

    return _ExerciseCategorySectionData(
      title: section.title,
      description: section.description,
      icon: section.icon,
      color: section.color,
      exercises: [...customEntries, ...section.exercises],
      errorMessage: section.errorMessage,
    );
  }).toList();
}

_CatalogExerciseEntry _mapCustomExercise(CustomExercise exercise) {
  return _CatalogExerciseEntry(
    exercise: Exercise(
      id: exercise.id,
      name: exercise.name,
      muscleGroup: exercise.muscleGroup,
      sets: exercise.sets,
      reps: exercise.reps,
      weight: exercise.weight,
    ),
    isCustom: true,
    sourceLabel: 'Custom Exercise',
    supportingText: exercise.intensity,
  );
}
