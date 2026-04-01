import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/reference/exercise_category_data.dart';
import '../../data/memory/custom_exercise_store.dart';
import '../../data/repositories/exercise_api_repository.dart';
import '../../data/models/api_exercise.dart';
import '../../domain/providers/routine_provider.dart';
import '../../models/custom_exercise.dart';
import '../../models/exercise.dart';
import '../navigation/app_router.dart';
import '../widgets/app_drawer.dart';

class ExerciseListScreen extends StatefulWidget {
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
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late Future<List<_ExerciseItem>> _apiExercisesFuture;

  @override
  void initState() {
    super.initState();
    _apiExercisesFuture = _loadApiExercises();
  }

  @override
  void didUpdateWidget(covariant ExerciseListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryName != widget.categoryName) {
      _apiExercisesFuture = _loadApiExercises();
    }
  }

  Future<List<_ExerciseItem>> _loadApiExercises() async {
    final apiType = apiTypeForCategory(widget.categoryName);
    if (apiType.isEmpty) {
      return const <_ExerciseItem>[];
    }

    final repository = context.read<ExerciseApiRepository>();
    final apiExercises = await repository.searchExercises(type: apiType);

    return apiExercises.map(_mapApiExercise).toList();
  }

  _ExerciseItem _mapApiExercise(ApiExercise apiExercise) {
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

    return _ExerciseItem(
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
      badgeLabel: 'API',
      badgeColor: widget.themeColor,
      supportingText: _buildSupportingText(apiExercise),
    );
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

  List<_ExerciseItem> _mergeExercises(
    List<CustomExercise> customExercises,
    List<_ExerciseItem> apiExercises,
  ) {
    final customEntries = customExercises
        .where((exercise) => categoryMatches(widget.categoryName, exercise.category))
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
            badgeLabel: 'Custom',
            badgeColor: Colors.green,
            supportingText: exercise.intensity,
            isCustom: true,
          ),
        )
        .toList();

    return <_ExerciseItem>[...customEntries, ...apiExercises];
  }

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(widget.themeColor);
    final foregroundColor =
        brightness == Brightness.dark ? Colors.white : Colors.black;
    final routineProvider = context.watch<RoutineProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(
        currentRouteName: AppRoute.exerciseList.name,
        currentCategoryName: widget.categoryName,
      ),
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        title: Text('${widget.categoryName} Exercises'),
        actions: const [DrawerBackAction()],
      ),
      body: ValueListenableBuilder<List<CustomExercise>>(
        valueListenable: CustomExerciseStore.exercises,
        builder: (context, customExercises, _) {
          return FutureBuilder<List<_ExerciseItem>>(
            future: _apiExercisesFuture,
            builder: (context, snapshot) {
              final apiExercises = snapshot.data ?? const <_ExerciseItem>[];
              final exercises = _mergeExercises(customExercises, apiExercises);

              if (snapshot.connectionState == ConnectionState.waiting &&
                  apiExercises.isEmpty &&
                  customExercises.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError && exercises.isEmpty) {
                return _CategoryErrorState(
                  categoryName: widget.categoryName,
                  themeColor: widget.themeColor,
                  errorMessage: snapshot.error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
                  onRetry: () {
                    setState(() {
                      _apiExercisesFuture = _loadApiExercises();
                    });
                  },
                );
              }

              if (exercises.isEmpty) {
                return _EmptyCategoryState(categoryName: widget.categoryName);
              }

              return Column(
                children: [
                  if (snapshot.hasError)
                    _InlineWarningBanner(
                      themeColor: widget.themeColor,
                      message:
                          'API data could not be refreshed. Showing only your custom exercises for now.',
                      onRetry: () {
                        setState(() {
                          _apiExercisesFuture = _loadApiExercises();
                        });
                      },
                    ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: exercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = exercises[index];
                        final exercise = entry.exercise;
                        final isInRoutine =
                            routineProvider.isInRoutine(exercise.id);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.of(context).pushRouteWithArgs(
                                AppRoute.exerciseDetail,
                                ExerciseDetailArgs(
                                  exercise: exercise,
                                  accentColor: widget.themeColor,
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
                                        : widget.themeColor.withValues(alpha: 0.28),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.themeColor.withValues(
                                        alpha: 0.14,
                                      ),
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
                                        color: widget.themeColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        widget.iconData,
                                        color: widget.themeColor,
                                      ),
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
                                              if (entry.badgeLabel != null)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: entry.badgeColor
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    entry.badgeLabel!,
                                                    style: TextStyle(
                                                      color: entry.badgeColor,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                          if (entry.supportingText.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              entry.supportingText,
                                              style: TextStyle(
                                                color: entry.isCustom
                                                    ? Colors.green
                                                    : widget.themeColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 6),
                                          Text(
                                            '${exercise.sets} sets | ${exercise.reps} reps | ${_formatWeight(exercise.weight)} kg',
                                            style: TextStyle(
                                              color: widget.themeColor,
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
                                                : Icons
                                                    .playlist_add_circle_outlined,
                                            color: isInRoutine
                                                ? Colors.green
                                                : widget.themeColor,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: widget.themeColor,
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
                    ),
                  ),
                ],
              );
            },
          );
        },
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

class _ExerciseItem {
  final Exercise exercise;
  final bool isCustom;
  final String? badgeLabel;
  final Color badgeColor;
  final String supportingText;

  const _ExerciseItem({
    required this.exercise,
    this.isCustom = false,
    this.badgeLabel,
    this.badgeColor = Colors.blueAccent,
    this.supportingText = '',
  });
}

class _InlineWarningBanner extends StatelessWidget {
  final Color themeColor;
  final String message;
  final VoidCallback onRetry;

  const _InlineWarningBanner({
    required this.themeColor,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: themeColor.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: themeColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
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
      ),
    );
  }
}

class _CategoryErrorState extends StatelessWidget {
  final String categoryName;
  final Color themeColor;
  final String errorMessage;
  final VoidCallback onRetry;

  const _CategoryErrorState({
    required this.categoryName,
    required this.themeColor,
    required this.errorMessage,
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
            Icon(Icons.cloud_off, color: themeColor, size: 40),
            const SizedBox(height: 12),
            Text(
              'Failed to load $categoryName exercises.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
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

class _EmptyCategoryState extends StatelessWidget {
  final String categoryName;

  const _EmptyCategoryState({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No exercises are available for $categoryName yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
