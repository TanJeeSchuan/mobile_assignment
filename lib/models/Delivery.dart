import 'dart:core';
import 'Workshop.dart';
import 'Warehouse.dart';

class Delivery {
  String delivery_id;
  List<String> attachments;
  DateTime delivery_by;
  Warehouse source_warehouse;
  Workshop destination_workshop;
  double weight;
  List<Stage> stages;

  Delivery(this.delivery_id, this.attachments, this.delivery_by,
      this.source_warehouse, this.destination_workshop, this.weight,
      this.stages);

  // fromJson(Map<String, dynamic> json) {
  //   return Delivery(
  //     json['delivery_id']
  // }
}

class Stage {
  final String stage;
  final bool status;
  DateTime timestamp = DateTime.fromMicrosecondsSinceEpoch(0);

  Stage(this.stage, this.status);
}