import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

final recipesNotifierProvider = AsyncNotifierProvider<RecipeNotifier, List<Recipe>>(
  RecipeNotifier.new,
);

final searchQueryProvider = NotifierProvider<SearchNotifier, String>(
  SearchNotifier.new,
);

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateSearch(String query) {
    state = query;
  }
}

final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final recipesAsync = ref.watch(recipesNotifierProvider);
  final query = ref.watch(searchQueryProvider);

  return recipesAsync.whenData((recipes) {
    if (query.isEmpty) {
      return recipes;
    }

    return recipes.where((recipe) {
      final titleMatch =
          recipe.title.toLowerCase().contains(query.toLowerCase());
      final ingredientsMatch = recipe.ingredients
          .any((ing) => ing.toLowerCase().contains(query.toLowerCase()));
      return titleMatch || ingredientsMatch;
    }).toList();
  }).value ?? [];
});

class RecipeNotifier extends AsyncNotifier<List<Recipe>> {
  late DatabaseService _dbService;

  @override
  Future<List<Recipe>> build() async {
    _dbService = ref.watch(databaseServiceProvider);
    return await _dbService.getAllRecipes();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _dbService.insertRecipe(recipe);
    ref.invalidateSelf();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _dbService.updateRecipe(recipe);
    ref.invalidateSelf();
  }

  Future<void> deleteRecipe(int id) async {
    await _dbService.deleteRecipe(id);
    ref.invalidateSelf();
  }
}
