import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/category_provider.dart';
import '../providers/item_provider.dart';
import '../models/category.dart' as cat;
import '../models/item.dart';

class AddItemPopup extends StatefulWidget {
  const AddItemPopup({super.key});

  @override
  AddItemPopupState createState() => AddItemPopupState();
}

class AddItemPopupState extends State<AddItemPopup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  cat.ItemCategory? _selectedCategory;
  bool _active = true;
  String? _imagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _add() {
    print('AddItemPopup: _add() called');
    print('AddItemPopup: Name: "${_nameController.text}", Category: ${_selectedCategory?.name}, Price: "${_priceController.text}", GST: "${_gstController.text}"');

    if (_nameController.text.isNotEmpty &&
        _selectedCategory != null &&
        _priceController.text.isNotEmpty &&
        _gstController.text.isNotEmpty) {
      try {
        Item item = Item(
          name: _nameController.text,
          categoryId: _selectedCategory!.id!,
          price: double.parse(_priceController.text),
          gstPercent: double.parse(_gstController.text),
          imagePath: _imagePath,
          active: _active,
        );
        print('AddItemPopup: Created item: ${item.name} with category ID: ${item.categoryId}');
        context.read<ItemProvider>().addItem(item);
        Navigator.of(context).pop();
      } catch (e) {
        print('AddItemPopup: Error creating item: $e');
      }
    } else {
      print('AddItemPopup: Validation failed - name: ${_nameController.text.isNotEmpty}, category: ${_selectedCategory != null}, price: ${_priceController.text.isNotEmpty}, gst: ${_gstController.text.isNotEmpty}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                DropdownButtonFormField<cat.ItemCategory>(
                  value: _selectedCategory,
                  items: categoryProvider.categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _gstController,
                  decoration: const InputDecoration(labelText: 'GST %'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
                const SizedBox(height: 10),
                _imagePath != null
                    ? Image.file(File(_imagePath!), height: 100)
                    : const Text('No Image Selected'),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
              ],
            ),
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
      },
    );
  }
}
