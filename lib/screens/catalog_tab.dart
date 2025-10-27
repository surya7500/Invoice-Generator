import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/category_provider.dart';
import '../providers/item_provider.dart';
import '../models/category.dart' as cat;
import '../models/item.dart';
import '../database/database_helper.dart';
import 'add_category_popup.dart';
import 'add_item_popup.dart';
import 'edit_item_popup.dart';
import 'edit_category_popup.dart';

class CatalogTab extends StatefulWidget {
  const CatalogTab({super.key});

  @override
  _CatalogTabState createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryProvider, ItemProvider>(
      builder: (context, categoryProvider, itemProvider, child) {
        List<cat.ItemCategory> categories = categoryProvider.categories;
        List<Item> items = itemProvider.items.where((item) {
          return item.name.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Items',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddCategoryPopup(),
                      );
                    },
                    child: const Text('Add Category'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddItemPopup(),
                      );
                    },
                    child: const Text('Add Item'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CategoryProvider>().loadCategories();
                      context.read<ItemProvider>().loadItems();
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No categories found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Try clicking "Refresh" to load data',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CategoryProvider>().loadCategories();
                              context.read<ItemProvider>().loadItems();
                            },
                            child: const Text('Load Data'),
                          ),
                        ],
                      ),
                    )
                  : DefaultTabController(
                      length: categories.length,
                      child: Column(
                        children: [
                          TabBar(
                            isScrollable: true,
                            tabs: categories.map((category) {
                              return Tab(
                                text: category.name,
                                icon: const Icon(Icons.category),
                              );
                            }).toList(),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: categories.map((category) {
                                List<Item> categoryItems = items.where((item) => item.categoryId == category.id).toList();
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              category.name,
                                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => EditCategoryPopup(category: category),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              context.read<CategoryProvider>().deleteCategory(category.id!);
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: categoryItems.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'No items in this category',
                                                style: TextStyle(fontSize: 16, color: Colors.grey),
                                              ),
                                            )
                                          : GridView.builder(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                          childAspectRatio: 0.65,
                                        ),
                                              itemCount: categoryItems.length,
                                              itemBuilder: (context, index) {
                                                Item item = categoryItems[index];
                                                return Card(
                                                  elevation: 4,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: item.imagePath != null && File(item.imagePath!).existsSync()
                                                          ? Image.file(
                                                              File(item.imagePath!),
                                                              fit: BoxFit.cover,
                                                              width: double.infinity,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                  width: double.infinity,
                                                                  color: Colors.grey[200],
                                                                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                                                );
                                                              },
                                                            )
                                                          : Container(
                                                              width: double.infinity,
                                                              color: Colors.grey[200],
                                                              child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                                            ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(4.0),
                                                        child: Text(
                                                          item.name,
                                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                        child: Text(
                                                          '₹${item.price}',
                                                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(4.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(Icons.edit, size: 16),
                                                              padding: EdgeInsets.zero,
                                                              onPressed: () {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => EditItemPopup(item: item),
                                                                );
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(Icons.delete, size: 16),
                                                              padding: EdgeInsets.zero,
                                                              onPressed: () {
                                                                context.read<ItemProvider>().deleteItem(item.id!);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
