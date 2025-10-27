import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
  }

  void _loadData() {
    context.read<InvoiceProvider>().loadInvoices(startDate: _startDate, endDate: _endDate);
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
        double totalSales = invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
        int totalInvoices = invoices.length;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _selectDateRange,
                child: const Text('Select Date Range'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.receipt, size: 40, color: Colors.blue),
                            const SizedBox(height: 10),
                            Text('Total Invoices', style: const TextStyle(fontSize: 16)),
                            Text('$totalInvoices', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.attach_money, size: 40, color: Colors.green),
                            const SizedBox(height: 10),
                            Text('Total Sales', style: const TextStyle(fontSize: 16)),
                            Text('₹$totalSales', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Recent Invoices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    Invoice invoice = invoices[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long, color: Colors.blue),
                        title: Text(invoice.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${invoice.date.toLocal().toString().split(' ')[0]} - ₹${invoice.total}'),
                        trailing: Text(invoice.tableNumber ?? 'N/A'),
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
