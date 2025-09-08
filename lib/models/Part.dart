class Part {
  final String id;
  final String barcode;
  final String name;
  final String category;
  final double price;

  Part({
    required this.id,
    required this.barcode,
    required this.name,
    required this.category,
    required this.price,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] ?? '',
      barcode: json['barcode'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'category': category,
      'price': price,
    };
  }
}