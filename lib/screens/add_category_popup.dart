import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as cat;

class AddCategoryPopup extends StatefulWidget {
  const AddCategoryPopup({super.key});

  @override
  AddCategoryPopupState createState() => AddCategoryPopupState();
}

class AddCategoryPopupState extends State<AddCategoryPopup> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _add() {
    print('AddCategoryPopup: _add() called with text: "${_nameController.text}"');
    if (_nameController.text.isNotEmpty) {
      cat.ItemCategory category = cat.ItemCategory(name: _nameController.text);
      print('AddCategoryPopup: Created category: ${category.name}');
      context.read<CategoryProvider>().addCategory(category);
      Navigator.of(context).pop();
    } else {
      print('AddCategoryPopup: Category name is empty, not adding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Category Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _add,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
