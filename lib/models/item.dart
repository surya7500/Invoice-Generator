class Item {
  int? id;
  String name;
  int categoryId;
  double price;
  double gstPercent;
  String? imagePath;
  bool active;

  Item({
    this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.gstPercent,
    this.imagePath,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'gstPercent': gstPercent,
      'imagePath': imagePath,
      'active': active ? 1 : 0,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      categoryId: map['categoryId'],
      price: map['price'],
      gstPercent: map['gstPercent'],
      imagePath: map['imagePath'],
      active: map['active'] == 1,
    );
  }
}
