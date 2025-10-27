import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../database/database_helper.dart';

class ItemProvider with ChangeNotifier {
  List<Item> _items = [];

  ItemProvider() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    await loadItems();
  }

  List<Item> get items => _items;

  Future<void> loadItems({int? categoryId}) async {
    _items = await DatabaseHelper().getItems(categoryId: categoryId);
    notifyListeners();
  }

  Future<void> addItem(Item item) async {
    print('ItemProvider: Adding item: ${item.name} with category ID: ${item.categoryId}');
    final itemId = await DatabaseHelper().insertItem(item);
    print('ItemProvider: Item inserted with ID: $itemId, reloading items...');
    await loadItems();
    print('ItemProvider: Items reloaded, total: ${_items.length}');
  }

  Future<void> updateItem(Item item) async {
    await DatabaseHelper().updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseHelper().deleteItem(id);
    await loadItems();
  }
}
