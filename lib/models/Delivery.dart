import 'dart:core';
import '../Defines.dart';
import 'DeliverySummary.dart';
import 'Workshop.dart';
import 'Warehouse.dart';
import 'Part.dart';

enum StageType {
  orderConfirmed,
  packingFinished,
  packagePickup,
  packageDropoff,
  orderComplete,
}

extension StageTypeExtension on StageType {
  String get value {
    switch (this) {
      case StageType.orderConfirmed:
        return "order_confirmed";
      case StageType.packingFinished:
        return "packing_finished";
      case StageType.packagePickup:
        return "package_pickup";
      case StageType.packageDropoff:
        return "package_dropoff";
      case StageType.orderComplete:
        return "order_complete";
    }
  }
}

class Delivery {
  final List<Attachment> attachments;
  final DateTime deliverBy;
  final Workshop destinationWorkshop;
  final List<DeliveryPart> packageDetails;
  final Warehouse sourceWarehouse;
  final List<Stage> stages;
  final double weight;
  String? delivery_id; // Optional field for database ID

  Delivery({
    required this.attachments,
    required this.deliverBy,
    required this.destinationWorkshop,
    required this.packageDetails,
    required this.sourceWarehouse,
    required this.stages,
    required this.weight,
    this.delivery_id,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      attachments: (json['attachments'] as List)
          .map((attachment) => Attachment.fromJson(attachment))
          .toList(),
      deliverBy: DateTime.parse(json['deliverBy']),
      destinationWorkshop: Workshop.fromJson(json['destinationWorkshop']),
      packageDetails: (json['packageDetails'] as List)
          .map((part) => DeliveryPart.fromJson(part))
          .toList(),
      sourceWarehouse: Warehouse.fromJson(json['sourceWarehouse']),
      stages: (json['stages'] as List)
          .map((stage) => Stage.fromJson(stage))
          .toList(),
      weight: (json['weight'] as num).toDouble(),
      delivery_id: json['deliveryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'deliverBy': deliverBy.toIso8601String(),
      'destinationWorkshop': destinationWorkshop.toJson(),
      'packageDetails': packageDetails.map((p) => p.toJson()).toList(),
      'sourceWarehouse': sourceWarehouse.toJson(),
      'stages': stages.map((s) => s.toJson()).toList(),
      'weight': weight,
      if (delivery_id != null) 'delivery_id': delivery_id,
    };
  }

  DeliverySummary toOrderSummary() {
    return DeliverySummary(
      orderId: delivery_id ?? 'N/A',  // Provide a default value if delivery_id is null
      deliverBy: deliverBy.toString(),
      weight: weight.toInt(),
      status: stages.isNotEmpty ? getStatusMessage(getLastCompleteStage(stages)!) : 'Unknown',
      source: sourceWarehouse.name,
      destination: destinationWorkshop.name,
    );
  }

  List<Map<String, dynamic>> toStages() {
    return stages.map((stage) => stage.toReadable()).toList();
  }

  List<Map<String, dynamic>> partsListToMap() {
    return packageDetails.map((part) {
      return {
        "code": part.code,
        "name": part.name,
        "qty": part.quantity
      };
    }).toList();
  }

  static String? getLastCompleteStage(List<Stage> stageList) {
    String? lastCompleted;
    
    for (final stage in stageList) {
      if (stage.status.booleanValue) {
        lastCompleted = stage.stage;
      } else {
        break; // Stop at first incomplete stage
      }
    }
    
    return lastCompleted;
  }

  static String getStatusMessage(String stage) {
    switch (stage) {
      case 'order_confirmed':
        return "Packing";
      case 'packing_finished':
        return "Ready To Ship";
      case 'package_pickup':
        return "In Transit";
      case 'package_dropoff':
        return "Package Arrived";
      case 'order_complete':
        return "Completed";
      default:
        return "Unknown";
    }
  }

  String getCurrentStage() {
    return getLastCompleteStage(stages) ?? 'Unknown';
  }

  String getNextVerificationStage() {
    String currentStage = getCurrentStage();
    if (currentStage == 'order_confirmed') {
      return "unauthorized";
    } else if (currentStage == 'packing_finished') {
      return "pickup";
    } else if (currentStage == 'package_pickup') {
      return "dropoff";
    } else {
      return "unauthorized";
    }
  }

  bool isPickupCompleted() {
    if (getCurrentStage() == StageType.packagePickup.value || getCurrentStage() == StageType.orderConfirmed.value || getCurrentStage() == StageType.packingFinished.value) {
      return false;
    }
    return true;
  }
}

class DeliveryPart {
  final String code;
  final String name;
  final int quantity;
  
  DeliveryPart({
    required this.code,
    required this.name,
    required this.quantity,
  });

  factory DeliveryPart.fromJson(Map<String, dynamic> json) {
    return DeliveryPart(
      code: json['code'],
      name: json['name'],
      quantity: json['qty'], // Changed from 'quantity' to 'qty' to match JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'qty': quantity, // Changed from 'quantity' to 'qty' to match JSON
    };
  }


}

class Attachment {
  final String description;
  final String downloadUrl;
  final String path;

  Attachment({
    required this.description,
    required this.downloadUrl,
    required this.path,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      description: json['description'],
      downloadUrl: json['downloadUrl'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'downloadUrl': downloadUrl,
      'path': path,
    };
  }
}

class Stage {
  final String stage;
  final StageStatus status;
  final DateTime? timestamp;

  Stage({
    required this.stage,
    required this.status,
    this.timestamp,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      stage: json['stage'],
      status: StageStatus.fromJson(json['status']),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'status': status.toJson(),
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  Map<String, dynamic> toReadable() {
    return {
      "stage": stageToReadable(stage),
      "status": status.booleanValue ? "Completed" : "Pending",
      "timestamp": timestamp != null 
          ? '${timestamp!.day} ${_getMonthAbbreviation(timestamp!.month)}, ${timestamp!.hour.toString().padLeft(2, '0')}.${timestamp!.minute.toString().padLeft(2, '0')}${timestamp!.hour < 12 ? 'am' : 'pm'}' 
          : 'N/A',
    };
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String stageToReadable(String stage) {
    switch (stage) {
      case 'order_confirmed':
        return "Order Confirmed";
        break;
      case 'packing_finished':
        return "Packing Finished";
      case 'package_pickup':
        return "Package Pickup";
      case 'package_dropoff':
        return "Package Dropoff";
      case 'order_complete':
        return "Order Complete";
      default:
        return "Unknown";
    }
  }
}

class StageStatus {
  final bool booleanValue;

  StageStatus({required this.booleanValue});

  factory StageStatus.fromJson(Map<String, dynamic> json) {
    return StageStatus(
      booleanValue: json['booleanValue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booleanValue': booleanValue,
    };
  }
}
