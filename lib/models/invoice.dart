import 'package:intl/intl.dart';

class Invoice {
  int? id;
  String? invoiceNumber;
  String customerName;
  String contact;
  String? tableNumber;
  bool gstApplied;
  double total;
  DateTime date;

  Invoice({
    this.id,
    this.invoiceNumber,
    required this.customerName,
    required this.contact,
    this.tableNumber,
    this.gstApplied = false,
    required this.total,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'contact': contact,
      'tableNumber': tableNumber,
      'gstApplied': gstApplied ? 1 : 0,
      'total': total,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      customerName: map['customerName'],
      contact: map['contact'],
      tableNumber: map['tableNumber'],
      gstApplied: map['gstApplied'] == 1,
      total: map['total'],
      date: DateFormat('yyyy-MM-dd HH:mm:ss').parse(map['date']),
    );
  }
}
