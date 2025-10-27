class ItemCategory {
  int? id;
  String name;
  bool active;

  ItemCategory({
    this.id,
    required this.name,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'active': active ? 1 : 0,
    };
  }

  factory ItemCategory.fromMap(Map<String, dynamic> map) {
    return ItemCategory(
      id: map['id'],
      name: map['name'],
      active: map['active'] == 1,
    );
  }
}
