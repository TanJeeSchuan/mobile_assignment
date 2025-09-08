class Workshop {
  final String id;
  final String name;
  final String contact;
  final String address;
  final DateTime? createdAt;

  Workshop({
    required this.id,
    required this.name,
    required this.contact,
    required this.address,
    this.createdAt,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}