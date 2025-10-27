import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as cat;

class EditCategoryPopup extends StatefulWidget {
  final cat.ItemCategory category;

  const EditCategoryPopup({super.key, required this.category});

  @override
  EditCategoryPopupState createState() => EditCategoryPopupState();
}

class EditCategoryPopupState extends State<EditCategoryPopup> {
  late TextEditingController _nameController;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _active = widget.category.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _update() {
    if (_nameController.text.isNotEmpty) {
      cat.ItemCategory updatedCategory = cat.ItemCategory(
        id: widget.category.id,
        name: _nameController.text,
        active: _active,
      );
      context.read<CategoryProvider>().updateCategory(updatedCategory);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          SwitchListTile(
            title: const Text('Active'),
            value: _active,
            onChanged: (value) => setState(() => _active = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _update,
          child: const Text('Update'),
        ),
      ],
    );
  }
}
