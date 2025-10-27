class HotelDetails {
  int? id;
  String name;
  String contact;
  String address;
  String gstin;
  String email;
  String? logoPath;
  String? backgroundPath;

  HotelDetails({
    this.id,
    required this.name,
    required this.contact,
    required this.address,
    required this.gstin,
    required this.email,
    this.logoPath,
    this.backgroundPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      'gstin': gstin,
      'email': email,
      'logoPath': logoPath,
      'backgroundPath': backgroundPath,
    };
  }

  factory HotelDetails.fromMap(Map<String, dynamic> map) {
    return HotelDetails(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      address: map['address'],
      gstin: map['gstin'],
      email: map['email'],
      logoPath: map['logoPath'],
      backgroundPath: map['backgroundPath'],
    );
  }
}
