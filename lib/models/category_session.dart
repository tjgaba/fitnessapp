class CategorySession {
  final int index;
  final bool completed;
  final List<String> exerciseIds;

  const CategorySession({
    required this.index,
    this.completed = false,
    this.exerciseIds = const [],
  });

  CategorySession copyWith({
    int? index,
    bool? completed,
    List<String>? exerciseIds,
  }) {
    return CategorySession(
      index: index ?? this.index,
      completed: completed ?? this.completed,
      exerciseIds: exerciseIds ?? this.exerciseIds,
    );
  }
}
