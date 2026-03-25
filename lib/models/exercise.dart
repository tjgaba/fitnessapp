class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double weight;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  double get volume => sets * reps * weight;

  factory Exercise.create({
    required String name,
    required String muscleGroup,
    required int sets,
    required int reps,
    required double weight,
  }) {
    return Exercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      muscleGroup: muscleGroup,
      sets: sets,
      reps: reps,
      weight: weight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
