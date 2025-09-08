import 'dart:convert';

import 'Part.dart';

class WarehouseStockItem {
  final String partID;
  final int qty;
  final String storageBay;

  const WarehouseStockItem({
    required this.partID,
    required this.qty,
    required this.storageBay,
  });

  factory WarehouseStockItem.fromJson(Map<String, dynamic> json) {
    return WarehouseStockItem(
      partID: json['partID'],
      qty: json['qty'] ?? 0,
      storageBay: json['storageBay'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partID': partID,
      'qty': qty,
      'storageBay': storageBay,
    };
  }
}

class Warehouse {
  final String id;
  final String name;
  final String address;
  final String contact;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, WarehouseStockItem>? stock;

  Warehouse({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.createdAt,
    this.updatedAt,
    this.stock,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    final stockMap = json['stock'] as Map<String, dynamic>?;
    
    return Warehouse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      contact: json['contact'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      stock: stockMap?.map((key, value) => MapEntry(
        key,
        WarehouseStockItem.fromJson(Map<String, dynamic>.from(value)),
      )),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contact': contact,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (stock != null) 'stock': stock!.map((key, value) => 
        MapEntry(key, value.toJson()),
      ),
    };
  }
}

