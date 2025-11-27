import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipe.dart';

class DatabaseService {
  static const String _databaseName = 'kitchenmate.db';
  static const String _tableName = 'recipes';
  static const int _databaseVersion = 1;

  static final DatabaseService _instance = DatabaseService._internal();

  late Database _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<void> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        steps TEXT NOT NULL,
        notes TEXT,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertRecipe(Recipe recipe) async {
    return await _database.insert(_tableName, recipe.toMap());
  }

  Future<List<Recipe>> getAllRecipes() async {
    final maps = await _database.query(_tableName);
    return List.generate(maps.length, (i) => Recipe.fromMap(maps[i]));
  }

  Future<Recipe?> getRecipeById(int id) async {
    final maps = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Recipe.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRecipe(Recipe recipe) async {
    return await _database.update(
      _tableName,
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    return await _database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final maps = await _database.query(
      _tableName,
      where: 'title LIKE ? OR ingredients LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Recipe.fromMap(maps[i]));
  }
}
