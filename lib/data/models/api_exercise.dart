class ApiExercise {
  final String name;
  final String type;
  final String muscle;
  final String difficulty;
  final String instructions;
  final List<String> equipments;
  final String safetyInfo;

  const ApiExercise({
    required this.name,
    required this.type,
    required this.muscle,
    required this.difficulty,
    required this.instructions,
    required this.equipments,
    required this.safetyInfo,
  });

  factory ApiExercise.fromJson(Map<String, dynamic> json) {
    final rawEquipments = json['equipments'];
    final parsedEquipments = rawEquipments is List
        ? rawEquipments
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>[];
    final singleEquipment = (json['equipment'] as String?)?.trim() ?? '';

    return ApiExercise(
      name: (json['name'] as String?)?.trim() ?? '',
      type: (json['type'] as String?)?.trim() ?? '',
      muscle: (json['muscle'] as String?)?.trim() ?? '',
      difficulty: (json['difficulty'] as String?)?.trim() ?? '',
      instructions: (json['instructions'] as String?)?.trim() ?? '',
      equipments: parsedEquipments.isNotEmpty
          ? parsedEquipments
          : (singleEquipment.isEmpty ? const <String>[] : <String>[singleEquipment]),
      safetyInfo: (json['safety_info'] as String?)?.trim() ?? '',
    );
  }
}
