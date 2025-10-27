import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../database/database_helper.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];

  InvoiceProvider() {
    Future.microtask(() => loadInvoices());
  }

  List<Invoice> get invoices => _invoices;

  Future<void> loadInvoices({DateTime? startDate, DateTime? endDate, String? search}) async {
    _invoices = await DatabaseHelper().getInvoices(startDate: startDate, endDate: endDate, search: search);
    notifyListeners();
  }

  Future<int> addInvoice(Invoice invoice, List<InvoiceItem> items, {bool autoGenerateNumber = true}) async {
    // Generate invoice number if auto-generation is enabled and no manual number is provided
    if (autoGenerateNumber && (invoice.invoiceNumber == null || invoice.invoiceNumber!.isEmpty)) {
      invoice.invoiceNumber = await DatabaseHelper().generateInvoiceNumber();
    }

    int invoiceId = await DatabaseHelper().insertInvoice(invoice);
    for (var item in items) {
      item.invoiceId = invoiceId;
      await DatabaseHelper().insertInvoiceItem(item);
    }
    await loadInvoices();
    return invoiceId;
  }

  Future<void> deleteInvoice(int id) async {
    await DatabaseHelper().deleteInvoice(id);
    await loadInvoices();
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    return await DatabaseHelper().getInvoiceItems(invoiceId);
  }
}
