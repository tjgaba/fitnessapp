class CustomExercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final String category;
  final String muscleGroup;
  final String intensity;
  final double totalVolume;
  final bool completed;

  const CustomExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.category,
    required this.muscleGroup,
    required this.intensity,
    required this.totalVolume,
    this.completed = false,
  });

  CustomExercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    double? weight,
    String? category,
    String? muscleGroup,
    String? intensity,
    double? totalVolume,
    bool? completed,
  }) {
    return CustomExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      category: category ?? this.category,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      intensity: intensity ?? this.intensity,
      totalVolume: totalVolume ?? this.totalVolume,
      completed: completed ?? this.completed,
    );
  }
}
