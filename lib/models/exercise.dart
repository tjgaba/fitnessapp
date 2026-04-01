class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double weight;
  final String instructions;
  final String safetyInfo;
  final List<String> equipments;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.weight,
    this.instructions = '',
    this.safetyInfo = '',
    this.equipments = const <String>[],
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'instructions': instructions,
      'safetyInfo': safetyInfo,
      'equipments': equipments,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final rawEquipments = json['equipments'];
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      instructions: (json['instructions'] as String?) ?? '',
      safetyInfo: (json['safetyInfo'] as String?) ?? '',
      equipments: rawEquipments is List
          ? rawEquipments.whereType<String>().toList()
          : const <String>[],
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    int? sets,
    int? reps,
    double? weight,
    String? instructions,
    String? safetyInfo,
    List<String>? equipments,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      instructions: instructions ?? this.instructions,
      safetyInfo: safetyInfo ?? this.safetyInfo,
      equipments: equipments ?? this.equipments,
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
