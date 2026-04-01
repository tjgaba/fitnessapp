import 'package:flutter/material.dart';

import '../../data/category_data.dart';
import '../app_router.dart';
import '../../models/custom_exercise.dart';
import '../widgets/app_drawer.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _selectedMuscleGroup;
  String? _selectedCategory;
  String? _selectedIntensity;

  @override
  void initState() {
    super.initState();
    _setsController.addListener(_updatePreview);
    _repsController.addListener(_updatePreview);
    _weightController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.removeListener(_updatePreview);
    _setsController.dispose();
    _repsController.removeListener(_updatePreview);
    _repsController.dispose();
    _weightController.removeListener(_updatePreview);
    _weightController.dispose();
    super.dispose();
  }

  int? get _setsValue => int.tryParse(_setsController.text.trim());
  int? get _repsValue => int.tryParse(_repsController.text.trim());
  double? get _weightValue => double.tryParse(_weightController.text.trim());

  double? get _totalVolume {
    final sets = _setsValue;
    final reps = _repsValue;
    final weight = _weightValue;
    if (sets == null || reps == null || weight == null) {
      return null;
    }
    return sets * reps * weight;
  }

  void _updatePreview() {
    if (mounted) {
      setState(() {});
    }
  }

  void _saveExercise() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final exercise = CustomExercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      sets: _setsValue!,
      reps: _repsValue!,
      weight: _weightValue!,
      category: _selectedCategory!,
      intensity: _selectedIntensity!,
      muscleGroup: _selectedMuscleGroup!,
      totalVolume: _totalVolume!,
    );

    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: AppDrawer(
        currentRouteName: AppRoute.addExercise.name,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Add Exercise',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [DrawerBackAction()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroCard(),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _nameController,
                  label: 'Exercise Name',
                  hint: 'e.g. Barbell Squat',
                  icon: Icons.fitness_center,
                  keyboardType: TextInputType.text,
                  validator: _validateExerciseName,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _setsController,
                  label: 'Sets',
                  hint: 'Enter number of sets',
                  icon: Icons.repeat,
                  keyboardType: TextInputType.number,
                  validator: _validateSets,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _repsController,
                  label: 'Reps',
                  hint: 'Enter reps per set',
                  icon: Icons.countertops_outlined,
                  keyboardType: TextInputType.number,
                  validator: _validateReps,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _weightController,
                  label: 'Weight',
                  hint: 'Enter weight used',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffixText: 'kg',
                  validator: _validateWeight,
                ),
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Select workout category...',
                    prefixIcon: const Icon(Icons.category_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: Colors.blueAccent.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  hint: const Text('Select workout category...'),
                  items: appCategories
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category.title,
                          child: Text(category.title),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),


                const SizedBox(height: 14),


                DropdownButtonFormField<String>(
                  initialValue: _selectedMuscleGroup,
                  decoration: InputDecoration(
                    labelText: 'Target Muscle Group',
                    hintText: 'Select Muscle Group...',
                    prefixIcon: const Icon(Icons.accessibility_new),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: Colors.blueAccent.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  hint: const Text('Select Muscle Group...'),
                  items: const [
                    DropdownMenuItem(value: 'Chest', child: Text('Chest')),
                    DropdownMenuItem(value: 'Back', child: Text('Back')),
                    DropdownMenuItem(value: 'Legs', child: Text('Legs')),
                    DropdownMenuItem(value: 'Arms', child: Text('Arms')),
                    DropdownMenuItem(
                      value: 'Shoulders',
                      child: Text('Shoulders'),
                    ),
                    DropdownMenuItem(value: 'Core', child: Text('Core')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedMuscleGroup = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a target muscle group';
                    }
                    return null;
                  },
                ),


                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: _selectedIntensity,
                  decoration: InputDecoration(
                    labelText: 'Intensity',
                    hintText: 'Select intensity level...',
                    prefixIcon: const Icon(Icons.local_fire_department_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: Colors.blueAccent.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  hint: const Text('Select intensity level...'),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(
                      value: 'Very High',
                      child: Text('Very High'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedIntensity = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an intensity';
                    }
                    return null;
                  },
                ),


                const SizedBox(height: 18),
                
                _buildVolumePreview(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveExercise,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Exercise'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a custom exercise',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Capture clean training data with strict validation before it reaches your workout log.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  Widget _buildVolumePreview() {
    final sets = _setsValue;
    final reps = _repsValue;
    final weight = _weightValue;
    final totalVolume = _totalVolume;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.18),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.blueAccent.withValues(alpha: 0.45),
          width: 1.4,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -24,
            right: -16,
            child: Container(
              width: 88,
              height: 88,
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
                children: const [
                  Icon(Icons.analytics_outlined,
                      color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Training Volume Preview',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Total Volume: ${sets ?? '--'} x ${reps ?? '--'} x ${weight?.toStringAsFixed(weight == weight.roundToDouble() ? 0 : 1) ?? '--'} = ${totalVolume?.toStringAsFixed(totalVolume == totalVolume.roundToDouble() ? 0 : 1) ?? '--'} kg',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _selectedMuscleGroup == null
                    ? 'Choose category, muscle group, and intensity to complete the exercise setup.'
                    : 'Category: ${_selectedCategory ?? '--'} | Target area: $_selectedMuscleGroup | Intensity: ${_selectedIntensity ?? '--'}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _validateExerciseName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Exercise name is required';
    }
    if (trimmed.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (trimmed.length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    return null;
  }

  String? _validateSets(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Number of sets is required';
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return 'Sets must be a whole number';
    }
    if (parsed <= 0) {
      return 'Sets must be greater than zero';
    }
    if (parsed > 20) {
      return 'Sets cannot exceed 20';
    }
    return null;
  }

  String? _validateReps(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Number of reps is required';
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return 'Reps must be a whole number';
    }
    if (parsed <= 0) {
      return 'Reps must be greater than zero';
    }
    if (parsed > 100) {
      return 'Reps cannot exceed 100';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Weight is required';
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      return 'Weight must be a valid number';
    }
    if (parsed < 0) {
      return 'Weight cannot be negative';
    }
    if (parsed > 500) {
      return 'Weight cannot exceed 500kg';
    }
    return null;
  }
}


