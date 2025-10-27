import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/category_provider.dart';
import '../providers/item_provider.dart';
import '../providers/invoice_provider.dart';
import '../models/item.dart';
import '../models/category.dart' as cat;
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'invoice_popup.dart';

class OrderTakingTab extends StatefulWidget {
  const OrderTakingTab({super.key});

  @override
  _OrderTakingTabState createState() => _OrderTakingTabState();
}

class _OrderTakingTabState extends State<OrderTakingTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _invoiceNumberController = TextEditingController();
  String _selectedCategory = 'All';
  bool _gstApplied = false;
  bool _manualInvoiceNumber = false;
  List<Map<String, dynamic>> _cart = [];
  double _total = 0.0;
  double _gstAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _contactController.dispose();
    _tableController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  void _filterItems() {
    setState(() {});
  }

  void _addToCart(Item item) {
    setState(() {
      int index = _cart.indexWhere((cartItem) => cartItem['item'].id == item.id);
      if (index != -1) {
        _cart[index]['quantity']++;
      } else {
        _cart.add({'item': item, 'quantity': 1});
      }
      _calculateTotal();
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _total = 0.0;
    _gstAmount = 0.0;
    for (var cartItem in _cart) {
      double price = cartItem['item'].price * cartItem['quantity'];
      _total += price;
      if (_gstApplied) {
        _gstAmount += price * (cartItem['item'].gstPercent / 100);
      }
    }
  }

  Future<void> _generateInvoice() async {
    if (_cart.isEmpty || _customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items and enter customer details')),
      );
      return;
    }

    Invoice invoice = Invoice(
      invoiceNumber: _manualInvoiceNumber && _invoiceNumberController.text.isNotEmpty
          ? _invoiceNumberController.text
          : null,
      customerName: _customerNameController.text,
      contact: _contactController.text,
      tableNumber: _tableController.text,
      gstApplied: _gstApplied,
      total: _total + _gstAmount,
    );

    List<InvoiceItem> invoiceItems = _cart.map((cartItem) {
      return InvoiceItem(
        invoiceId: 0, // Temporary value, will be updated in addInvoice
        itemId: cartItem['item'].id!,
        quantity: cartItem['quantity'],
        price: cartItem['item'].price,
      );
    }).toList();

    int invoiceId = await context.read<InvoiceProvider>().addInvoice(
      invoice,
      invoiceItems,
      autoGenerateNumber: !_manualInvoiceNumber,
    );
    invoice.id = invoiceId;

    showDialog(
      context: context,
      builder: (context) => InvoicePopup(invoice: invoice, items: invoiceItems),
    );

    // Clear cart and fields
    setState(() {
      _cart.clear();
      _customerNameController.clear();
      _contactController.clear();
      _tableController.clear();
      _invoiceNumberController.clear();
      _manualInvoiceNumber = false;
      _total = 0.0;
      _gstAmount = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryProvider, ItemProvider>(
      builder: (context, categoryProvider, itemProvider, child) {
        List<cat.ItemCategory> categories = categoryProvider.categories;
        String selectedCategory = _selectedCategory;
        List<Item> filteredItems = itemProvider.items.where((item) {
          bool matchesSearch = item.name.toLowerCase().contains(_searchController.text.toLowerCase());
          bool matchesCategory = selectedCategory == 'All' || (categories.isNotEmpty && categories.any((c) => c.name == selectedCategory && item.categoryId == c.id));
          return matchesSearch && matchesCategory;
        }).toList();

        return Row(
          children: [
            // Left: Categories and Item Grid
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Items',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                      ),
                    ),
                  ),
                  // Category Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'All';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedCategory == 'All' ? Colors.blue : Colors.grey,
                            ),
                            child: const Text('All'),
                          ),
                        ),
                        ...categories.map((c) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = c.name;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedCategory == c.name ? Colors.blue : Colors.grey,
                              ),
                              child: Text(c.name),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        Item item = filteredItems[index];
                        return Card(
                          child: Column(
                            children: [
                              Expanded(
                                child: item.imagePath != null && File(item.imagePath!).existsSync()
                                  ? Image.file(
                                      File(item.imagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                        );
                                      },
                                    )
                                  : Container(
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
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _addToCart(item),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      textStyle: const TextStyle(fontSize: 10),
                                    ),
                                    child: const Text('Add'),
                                  ),
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
            ),
            // Right: Cart
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(labelText: 'Customer Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _contactController,
                        decoration: const InputDecoration(labelText: 'Contact Number'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _tableController,
                        decoration: const InputDecoration(labelText: 'Table/Room Number'),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text('Manual Invoice Number'),
                        value: _manualInvoiceNumber,
                        onChanged: (value) {
                          setState(() {
                            _manualInvoiceNumber = value;
                          });
                        },
                      ),
                      if (_manualInvoiceNumber) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _invoiceNumberController,
                          decoration: const InputDecoration(labelText: 'Invoice Number'),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text('Apply GST'),
                        value: _gstApplied,
                        onChanged: (value) {
                          setState(() {
                            _gstApplied = value;
                            _calculateTotal();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text('Cart Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            var cartItem = _cart[index];
                            return Card(
                              child: ListTile(
                                title: Text(cartItem['item'].name),
                                subtitle: Text('Qty: ${cartItem['quantity']} - ₹${cartItem['item'].price * cartItem['quantity']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeFromCart(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Text('Subtotal: ₹$_total', style: const TextStyle(fontSize: 16)),
                              if (_gstApplied) Text('GST: ₹$_gstAmount', style: const TextStyle(fontSize: 16)),
                              Text('Total: ₹${_total + _gstAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _generateInvoice,
                                child: const Text('Generate Bill'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
