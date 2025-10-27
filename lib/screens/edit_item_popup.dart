import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/category_provider.dart';
import '../providers/item_provider.dart';
import '../models/category.dart' as cat;
import '../models/item.dart';

class EditItemPopup extends StatefulWidget {
  final Item item;

  const EditItemPopup({super.key, required this.item});

  @override
  EditItemPopupState createState() => EditItemPopupState();
}

class EditItemPopupState extends State<EditItemPopup> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _gstController;
  cat.ItemCategory? _selectedCategory;
  bool _active = true;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.price.toString());
    _gstController = TextEditingController(text: widget.item.gstPercent.toString());
    _active = widget.item.active;
    _imagePath = widget.item.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _update() {
    if (_nameController.text.isNotEmpty && _selectedCategory != null) {
      Item updatedItem = Item(
        id: widget.item.id,
        name: _nameController.text,
        categoryId: _selectedCategory!.id!,
        price: double.parse(_priceController.text),
        gstPercent: double.parse(_gstController.text),
        active: _active,
        imagePath: _imagePath,
      );
      context.read<ItemProvider>().updateItem(updatedItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (_selectedCategory == null) {
          _selectedCategory = categoryProvider.categories.firstWhere((cat) => cat.id == widget.item.categoryId);
        }
        return AlertDialog(
          title: const Text('Edit Item'),
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
              onPressed: _update,
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
