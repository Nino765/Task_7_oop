import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

class DatabaseService {
  static const String _boxName = 'recipes';
  static final DatabaseService _instance = DatabaseService._internal();

  late Box<Recipe> _box;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<void> initDb() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    _box = await Hive.openBox<Recipe>(_boxName);
  }

  Future<int> insertRecipe(Recipe recipe) async {
    await _box.add(recipe.copyWith(id: null));
    return _box.length - 1;
  }

  Future<List<Recipe>> getAllRecipes() async {
    final recipes = _box.values.toList();
    return recipes.map((r) => r.copyWith(id: _box.keys.toList()[_box.values.toList().indexOf(r)])).toList();
  }

  Future<Recipe?> getRecipeById(int id) async {
    try {
      final recipe = _box.getAt(id);
      return recipe?.copyWith(id: id);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateRecipe(Recipe recipe) async {
    if (recipe.id != null) {
      await _box.putAt(recipe.id!, recipe);
      return 1;
    }
    return 0;
  }

  Future<int> deleteRecipe(int id) async {
    await _box.deleteAt(id);
    return 1;
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final recipes = _box.values.toList();
    final filtered = recipes.where((recipe) {
      final titleMatch = recipe.title.toLowerCase().contains(query.toLowerCase());
      final ingredientsMatch = recipe.ingredients
          .any((ing) => ing.toLowerCase().contains(query.toLowerCase()));
      return titleMatch || ingredientsMatch;
    }).toList();
    
    return filtered.map((r) => r.copyWith(id: _box.keys.toList()[_box.values.toList().indexOf(r)])).toList();
  }
}

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final typeId = 0;

  @override
  Recipe read(BinaryReader reader) {
    final title = reader.readString();
    final ingredientsStr = reader.readString();
    final stepsStr = reader.readString();
    final notes = reader.readString();
    final category = reader.readString();
    final createdAtStr = reader.readString();

    return Recipe(
      title: title,
      ingredients: ingredientsStr.split('|'),
      steps: stepsStr.split('|'),
      notes: notes.isEmpty ? null : notes,
      category: category,
      createdAt: DateTime.parse(createdAtStr),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.ingredients.join('|'));
    writer.writeString(obj.steps.join('|'));
    writer.writeString(obj.notes ?? '');
    writer.writeString(obj.category);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}
