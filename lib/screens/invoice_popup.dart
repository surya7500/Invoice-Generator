import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import '../providers/hotel_provider.dart';
import '../providers/item_provider.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/item.dart';

class InvoicePopup extends StatelessWidget {
  final Invoice invoice;
  final List<InvoiceItem> items;

  const InvoicePopup({super.key, required this.invoice, required this.items});

  Future<void> _printInvoice(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) => _generatePdf(context),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $e')),
      );
    }
  }

  Future<Uint8List> _generatePdf(BuildContext context) async {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    Map<int, Item> itemMap = {for (var item in itemProvider.items) item.id!: item};

    String invoiceContent = '''
${hotelProvider.hotelDetails?.name ?? 'Restaurant'}

${hotelProvider.hotelDetails?.address ?? ''}
${hotelProvider.hotelDetails?.contact ?? ''}
${invoice.gstApplied ? 'GSTIN: ${hotelProvider.hotelDetails?.gstin ?? ''}' : ''}

${invoice.invoiceNumber != null && invoice.invoiceNumber!.isNotEmpty ? 'Invoice Number: ${invoice.invoiceNumber}' : ''}

Customer: ${invoice.customerName}
Contact: ${invoice.contact}
${invoice.tableNumber != null ? 'Table: ${invoice.tableNumber}' : ''}

Items:
${items.map((item) {
      Item? itemDetails = itemMap[item.itemId];
      double itemTotal = item.price * item.quantity;
      double itemGst = invoice.gstApplied ? itemTotal * (itemDetails?.gstPercent ?? 0) / 100 : 0;
      return '${itemDetails?.name ?? 'Unknown'} x${item.quantity} - ₹${itemTotal + itemGst}';
    }).join('\n')}

${(() {
      double subtotal = items.fold(0.0, (sum, item) {
        return sum + (item.price * item.quantity);
      });
      double gstAmount = invoice.gstApplied ? (invoice.total - subtotal) : 0.0;
      return '''
Subtotal: ₹$subtotal
${invoice.gstApplied ? 'GST: ₹$gstAmount' : ''}
Total: ₹${invoice.total}

Thank you for your visit!
''';
    })()}
''';

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(invoiceContent, style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HotelProvider, ItemProvider>(
      builder: (context, hotelProvider, itemProvider, child) {
        Map<int, Item> itemMap = {for (var item in itemProvider.items) item.id!: item};
        return AlertDialog(
          title: const Text('Invoice'),
          content: Container(
            width: 300,
            decoration: BoxDecoration(
              image: hotelProvider.hotelDetails?.backgroundPath != null
                ? DecorationImage(
                    image: FileImage(File(hotelProvider.hotelDetails!.backgroundPath!)),
                    fit: BoxFit.cover,
                    opacity: 0.1,
                  )
                : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (hotelProvider.hotelDetails?.logoPath != null)
                        Image.file(File(hotelProvider.hotelDetails!.logoPath!), height: 50),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (invoice.invoiceNumber != null && invoice.invoiceNumber!.isNotEmpty)
                            Text('Invoice: ${invoice.invoiceNumber}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(hotelProvider.hotelDetails?.name ?? 'Restaurant', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(hotelProvider.hotelDetails?.contact ?? ''),
                          Text(hotelProvider.hotelDetails?.address ?? ''),
                          if (invoice.gstApplied) Text('GSTIN: ${hotelProvider.hotelDetails?.gstin ?? ''}'),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                Text('Customer: ${invoice.customerName}'),
                Text('Contact: ${invoice.contact}'),
                if (invoice.tableNumber != null) Text('Table: ${invoice.tableNumber}'),
                const Divider(),
                ...items.map((item) {
                  Item? itemDetails = itemMap[item.itemId];
                  double itemTotal = item.price * item.quantity;
                  double itemGst = invoice.gstApplied ? itemTotal * (itemDetails?.gstPercent ?? 0) / 100 : 0;
                  return Text('${itemDetails?.name ?? 'Unknown'} x${item.quantity} - ₹${itemTotal + itemGst}');
                }),
                const Divider(),
                ...(() {
                  double subtotal = items.fold(0.0, (sum, item) {
                    return sum + (item.price * item.quantity);
                  });
                  double gstAmount = invoice.gstApplied ? (invoice.total - subtotal) : 0.0;
                  return [
                    Text('Subtotal: ₹$subtotal'),
                    if (invoice.gstApplied) Text('GST: ₹$gstAmount'),
                    Text('Total: ₹${invoice.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ];
                })(),
                const Text('Thank you for your visit!'),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () => _printInvoice(context),
              icon: const Icon(Icons.print),
              label: const Text('Print'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
