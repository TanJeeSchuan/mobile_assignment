import 'Part.dart';

class Warehouse {
  String id;
  String name;
  String address;
  String contact;
  late List<Part> parts;

  Warehouse(this.id, this.name, this.address, this.contact);
}

