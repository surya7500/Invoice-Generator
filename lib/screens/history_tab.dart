import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'invoice_popup.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_loadData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<InvoiceProvider>().loadInvoices(
      startDate: _startDate,
      endDate: _endDate,
      search: _searchController.text,
    );
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        List<Invoice> invoices = invoiceProvider.invoices;

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
                        labelText: 'Search by Name/Contact',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _selectDateRange,
                    child: const Text('Date Range'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    Invoice invoice = invoices[index];
                    return Card(
                      child: ListTile(
                        title: Text(invoice.customerName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (invoice.invoiceNumber != null && invoice.invoiceNumber!.isNotEmpty)
                              Text('Invoice: ${invoice.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Contact: ${invoice.contact}'),
                            Text('Date: ${invoice.date.toLocal().toString().split(' ')[0]}'),
                            Text('Total: ₹${invoice.total}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.print),
                              onPressed: () async {
                                try {
                                  List<InvoiceItem> items = await context.read<InvoiceProvider>().getInvoiceItems(invoice.id!);
                                  showDialog(
                                    context: context,
                                    builder: (context) => InvoicePopup(invoice: invoice, items: items),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error loading invoice: $e')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                context.read<InvoiceProvider>().deleteInvoice(invoice.id!);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
