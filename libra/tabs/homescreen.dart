import 'package:flutter/material.dart';

import '../data/custom_exercise_store.dart';
import '../models/custom_exercise.dart';
import '../screens/add_exercise_screen.dart';
import '../widgets/category_tile.dart';
import '../widgets/home_banner.dart';
import '../data/category_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isExerciseSectionExpanded = true;

  int getCrossAxisCount(double width) {
    if (width >= 1024) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  Future<void> _openAddExerciseScreen() async {
    final exerciseData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
    );

    if (exerciseData == null) {
      return;
    }

    final customExercise = CustomExercise(
      id: exerciseData['id'] as String,
      name: exerciseData['name'] as String,
      sets: exerciseData['sets'] as int,
      reps: exerciseData['reps'] as int,
      weight: exerciseData['weight'] as double,
      category: exerciseData['category'] as String,
      muscleGroup: exerciseData['muscleGroup'] as String,
      intensity: exerciseData['intensity'] as String,
      totalVolume: exerciseData['totalVolume'] as double,
    );

    setState(() {
      CustomExerciseStore.add(customExercise);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customExercise.name} saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        title: const Text('Fitness Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Open BMI Calculator',
              onPressed: () => Navigator.pushNamed(context, '/bmi'),
              icon: const Icon(Icons.monitor_weight_outlined),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExerciseScreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const HomeBanner(),
            _buildExerciseSection(),
            const SizedBox(height: 20),
            GridView.builder(
              itemCount: appCategories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: getCrossAxisCount(width),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 170,
              ),
              itemBuilder: (context, index) {
                return CategoryTile(category: appCategories[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection() {
    return ValueListenableBuilder<List<CustomExercise>>(
      valueListenable: CustomExerciseStore.exercises,
      builder: (context, customExercises, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.25),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.12),
                blurRadius: 14,
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
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.playlist_add_check_circle_outlined,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Custom Exercises',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${customExercises.length}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _isExerciseSectionExpanded =
                              !_isExerciseSectionExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isExerciseSectionExpanded
                                  ? 'Minimize'
                                  : 'Expand',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _isExerciseSectionExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.green,
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

              if (!_isExerciseSectionExpanded)
                Text(
                  customExercises.isEmpty
                      ? 'Section minimized. No custom exercises saved yet.'
                      : 'Section minimized. ${customExercises.length} custom exercise(s) saved.',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                )
              else if (customExercises.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Text(
                    'No custom exercises yet. Use the Add Exercise button to create one and validate it before it enters your log.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                )
              else
                Column(
                  children: customExercises
                      .map((exercise) => _buildExerciseTile(exercise))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseTile(CustomExercise exercise) {
    // CustomExerciseStore Data
    final muscleGroup = exercise.muscleGroup;
    final category = exercise.category;
    final intensity = exercise.intensity;
    final totalVolume = exercise.totalVolume;
    final weight = exercise.weight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.16),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.blueAccent.withValues(alpha: 0.4),
          width: 1.3,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -18,
            right: -10,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sports_gymnastics,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${exercise.sets} sets | ${exercise.reps} reps | ${_formatNumber(weight)} kg',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$muscleGroup | $intensity intensity',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Total Volume: ${_formatNumber(totalVolume)} kg',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
