class Recipe {
  final int? id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String? notes;
  final String category;
  final DateTime createdAt;

  Recipe({
    this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.notes,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients.join('|'),
      'steps': steps.join('|'),
      'notes': notes,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String,
      ingredients: (map['ingredients'] as String).split('|'),
      steps: (map['steps'] as String).split('|'),
      notes: map['notes'] as String?,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Recipe copyWith({
    int? id,
    String? title,
    List<String>? ingredients,
    List<String>? steps,
    String? notes,
    String? category,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
