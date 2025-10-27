class InvoiceItem {
  int? id;
  int invoiceId;
  int itemId;
  int quantity;
  double price;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.itemId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'itemId': itemId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoiceId'],
      itemId: map['itemId'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
