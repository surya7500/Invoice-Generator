import 'package:flutter/foundation.dart';
import '../models/category.dart' as cat;
import '../database/database_helper.dart';

class CategoryProvider with ChangeNotifier {
  List<cat.ItemCategory> _categories = [];

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await loadCategories();
  }

  List<cat.ItemCategory> get categories => _categories;

  Future<void> loadCategories() async {
    _categories = await DatabaseHelper().getCategories();
    notifyListeners();
  }

  Future<void> addCategory(cat.ItemCategory category) async {
    print('CategoryProvider: Adding category: ${category.name}');
    final categoryId = await DatabaseHelper().insertCategory(category);
    print('CategoryProvider: Category inserted with ID: $categoryId, reloading categories...');
    await loadCategories();
    print('CategoryProvider: Categories reloaded, total: ${_categories.length}');
  }

  Future<void> updateCategory(cat.ItemCategory category) async {
    await DatabaseHelper().updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await DatabaseHelper().deleteCategory(id);
    await loadCategories();
  }
}
