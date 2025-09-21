import 'dart:core';

import 'package:mobile_assignment/models/Warehouse.dart';

import 'DeliverySummary.dart';
import 'Workshop.dart';

class DeliveryAttachment {
  final String description;
  final String downloadUrl;
  final String path;

  DeliveryAttachment({
    required this.description,
    required this.downloadUrl,
    required this.path,
  });

  factory DeliveryAttachment.fromJson(Map<String, dynamic> json) {
    return DeliveryAttachment(
      description: json['description'] ?? "",
      downloadUrl: json['downloadUrl'] ?? "",
      path: json['path'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "downloadUrl": downloadUrl,
      "path": path,
    };
  }
}

class DeliveryPart {
  final String partId;
  final String name;
  final int qty;
  final String barcode;
  final String code;

  DeliveryPart({
    this.partId = "",
    required this.name,
    required this.qty,
    this.barcode = "",
    required this.code,
  });

  factory DeliveryPart.fromJson(Map<String, dynamic> json) {
    return DeliveryPart(
      partId: json['partID'] ?? "",
      name: json['name'] ?? "",
      qty: json['qty'] ?? 0,
      barcode: json['barcode'] ?? "",
      code: json['code'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "partID": partId,
      "name": name,
      "qty": qty,
      "barcode": barcode,
      "code": code,
    };
  }
}

class DeliveryStage {
  final String stage;
  final bool status;
  final DateTime? timestamp;

  DeliveryStage({
    required this.stage,
    required this.status,
    this.timestamp,
  });

  factory DeliveryStage.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    bool parsedStatus = false;

    if (rawStatus is Map && rawStatus.containsKey("booleanValue")) {
      parsedStatus = rawStatus['booleanValue'] == true;
    } else if (rawStatus is bool) {
      parsedStatus = rawStatus;
    }

    return DeliveryStage(
      stage: json['stage'] ?? "",
      status: parsedStatus,
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "stage": stage,
      "status": {"booleanValue": status},
      "timestamp": timestamp?.toIso8601String(),
    };
  }
}

class DeliveryVerification {
  final List<DeliveryAttachment> attachments;
  final DateTime? verifiedAt;
  final String verifiedBy;
  final String? verifiedById;
  final String? verifiedByName;
  final String? recipientId;
  final String? recipientName;

  DeliveryVerification({
    this.attachments = const [],
    this.verifiedAt,
    this.verifiedBy = "",
    this.verifiedById,
    this.verifiedByName,
    this.recipientId,
    this.recipientName,
  });

  factory DeliveryVerification.fromJson(Map<String, dynamic> json) {
    // Normalize attachments into List<DeliveryAttachment>
    final rawAttachments = json['attachments'] as List? ?? [];
    final parsedAttachments = rawAttachments.map((a) {
      if (a is Map<String, dynamic>) {
        return DeliveryAttachment.fromJson(a);
      } else if (a is String) {
        return DeliveryAttachment(
          description: "Attachment",
          downloadUrl: a,
          path: a,
        );
      } else {
        return DeliveryAttachment(
          description: "",
          downloadUrl: "",
          path: "",
        );
      }
    }).toList();

    // Handle verifiedAt: could be string (ISO) or timestamp (map)
    DateTime? parsedVerifiedAt;
    final rawVerifiedAt = json['verifiedAt'];
    if (rawVerifiedAt != null) {
      if (rawVerifiedAt is String) {
        parsedVerifiedAt = DateTime.tryParse(rawVerifiedAt);
      } else if (rawVerifiedAt is Map && rawVerifiedAt['_seconds'] != null) {
        // Firestore timestamp style
        parsedVerifiedAt = DateTime.fromMillisecondsSinceEpoch(
          (rawVerifiedAt['_seconds'] as int) * 1000,
        );
      }
    }

    return DeliveryVerification(
      attachments: parsedAttachments,
      verifiedAt: parsedVerifiedAt,
      verifiedBy: json['verifiedBy']?.toString() ?? "",
      verifiedById: json['verifiedById']?.toString(),
      verifiedByName: json['verifiedByName']?.toString(),
      recipientId: json['recipientId']?.toString(),
      recipientName: json['recipientName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "attachments": attachments.map((a) => a.toJson()).toList(),
      "verifiedAt": verifiedAt?.toIso8601String(),
      "verifiedBy": verifiedBy,
      if (verifiedById != null) "verifiedById": verifiedById,
      if (verifiedByName != null) "verifiedByName": verifiedByName,
      if (recipientId != null) "recipientId": recipientId,
      if (recipientName != null) "recipientName": recipientName,
    };
  }
}


class DeliveryVerificationMap {
  final DeliveryVerification? pickup;
  final DeliveryVerification? dropoff;

  DeliveryVerificationMap({this.pickup, this.dropoff});

  factory DeliveryVerificationMap.fromJson(Map<String, dynamic> json) {
    return DeliveryVerificationMap(
      pickup: json['pickup'] != null
          ? DeliveryVerification.fromJson(json['pickup'])
          : null,
      dropoff: json['dropoff'] != null
          ? DeliveryVerification.fromJson(json['dropoff'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup': pickup?.toJson(),
      'dropoff': dropoff?.toJson(),
    };
  }
}

class Delivery {
  final String deliveryId;
  final List<DeliveryAttachment> attachments;
  final DateTime? deliverBy;
  final Workshop? destinationWorkshop;
  final List<DeliveryPart> packageDetails;
  final Warehouse? sourceWarehouse;
  final List<DeliveryStage> stages;
  final DeliveryVerificationMap? verification;

  Delivery({
    required this.deliveryId,
    this.attachments = const [],
    this.deliverBy,
    this.destinationWorkshop,
    this.packageDetails = const [],
    this.sourceWarehouse,
    this.stages = const [],
    this.verification,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      deliveryId: json['deliveryId'] ?? "",
      attachments: (json['attachments'] as List? ?? [])
          .map((a) {
        if (a is Map<String, dynamic>) {
          return DeliveryAttachment.fromJson(a);
        } else if (a is String) {
          // fallback for when backend gives just a URL
          return DeliveryAttachment(
            description: "Attachment",
            downloadUrl: a,
            path: a,
          );
        } else {
          return DeliveryAttachment(description: "", downloadUrl: "", path: "");
        }
      })
          .toList(),
      deliverBy: json['deliverBy'] != null ? DateTime.tryParse(json['deliverBy']) : null,
      destinationWorkshop: json['destinationWorkshop'] != null
          ? Workshop.fromJson(json['destinationWorkshop'])
          : null,
      packageDetails: (json['packageDetails'] as List? ?? [])
          .map((p) => DeliveryPart.fromJson(p))
          .toList(),
      sourceWarehouse: json['sourceWarehouse'] != null
          ? Warehouse.fromJson(json['sourceWarehouse'])
          : null,
      stages: (json['stages'] as List? ?? [])
          .map((s) => DeliveryStage.fromJson(s))
          .toList(),
        verification: json['verification'] != null
            ? DeliveryVerificationMap.fromJson(json['verification'])
            : DeliveryVerificationMap(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "deliveryId": deliveryId,
      "attachments": attachments.map((a) => a.toJson()).toList(),
      "deliverBy": deliverBy?.toIso8601String(),
      "destinationWorkshop": destinationWorkshop?.toJson(),
      "packageDetails": packageDetails.map((p) => p.toJson()).toList(),
      "sourceWarehouse": sourceWarehouse?.toJson(),
      "stages": stages.map((s) => s.toJson()).toList(),
      "verification": verification?.toJson(), // <--- serialize as a map
    };
  }

  String? getCurrentStage() {
    String? current;
    for (final stage in stages) {
      if (stage.status) {
        current = stage.stage;
      } else {
        break;
      }
    }
    return current;
  }

  String getCurrentStageName() {
    final stage = getCurrentStage();
    switch (stage) {
      case "order_confirmed":
        return "packing";
      case "packing_finished":
        return "ready";
      case "package_pickup":
        return "transit";
      case "package_dropoff":
      case "order_complete":
        return "arrived";
      default:
        return "unknown";
    }
  }

  bool isPickupVerified(){
    final pickup = verification?.pickup;
    return pickup != null &&
        pickup.verifiedAt != null;
  }

  bool isDropoffVerified(){
    final dropoff = verification?.dropoff;
    return dropoff != null &&
        dropoff.verifiedAt != null;
  }

  /// Generates a DeliverySummary object
  DeliverySummary toOrderSummary() {
    final lastStage = getLastCompleteStage();
    return DeliverySummary(
      orderId: deliveryId,
      deliverBy: deliverBy?.toIso8601String() ?? '',
      weight: packageDetails.fold<int>(0, (sum, p) => sum + p.qty),
      status: lastStage != null ? stageToStatusMessage(lastStage) : 'Unknown',
      source: sourceWarehouse!.id,
      destination: destinationWorkshop!.id,
    );
  }
}

extension DeliveryHelpers on Delivery {
  /// Returns a list of stage info as maps (readable & formatted)
  List<Map<String, dynamic>> toStages() {
    return stages.map((s) {
      return {
        "stage": stageToReadable(s.stage),
        "status": s.status ? "Completed" : "Pending",
        "timestamp": s.timestamp != null
            ? '${s.timestamp!.day} ${_getMonthAbbr(s.timestamp!.month)}, ${s.timestamp!.hour.toString().padLeft(2,'0')}.${s.timestamp!.minute.toString().padLeft(2,'0')}${s.timestamp!.hour < 12 ? 'am' : 'pm'}'
            : 'N/A',
      };
    }).toList();
  }

  /// Converts packageDetails into a list of maps
  List<Map<String, dynamic>> partsListToMap() {
    return packageDetails.map((p) {
      return {
        "code": p.code,
        "name": p.name,
        "qty": p.qty,
        "barcode": p.barcode,
        "partID": p.partId,
      };
    }).toList();
  }

  /// Returns last completed stage (stage string)
  String? getLastCompleteStage() {
    String? lastCompleted;
    for (final s in stages) {
      if (s.status) {
        lastCompleted = s.stage;
      } else {
        break;
      }
    }
    return lastCompleted;
  }

  /// Converts internal stage string to user-friendly text
  String stageToReadable(String stage) {
    switch (stage) {
      case 'order_confirmed':
        return "Order Confirmed";
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

  /// Month abbreviation helper
  String _getMonthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  /// Determines next verification stage
  String getNextVerificationStage() {
    final current = getCurrentStage();
    switch (current) {
      case 'order_confirmed':
        return "unauthorized";
      case 'packing_finished':
        return "pickup";
      case 'package_pickup':
        return "dropoff";
      default:
        return "unauthorized";
    }
  }

  /// Checks if pickup is completed
  bool isPickupCompleted() {
    final stage = getCurrentStage();
    return stage == 'package_dropoff' || stage == 'order_complete';
  }

  /// Generates a summary similar to old `DeliverySummary`
  // Map<String, dynamic> toOrderSummary() {
  //   final lastStage = getLastCompleteStage();
  //   return {
  //     "orderId": destinationWorkshopId, // adapt as needed
  //     "deliverBy": deliverBy?.toIso8601String() ?? '',
  //     "weight": packageDetails.fold<int>(0, (sum, p) => sum + p.qty),
  //     "status": lastStage != null ? stageToStatusMessage(lastStage) : 'Unknown',
  //     "source": sourceWarehouseId,
  //     "destination": destinationWorkshopId,
  //   };
  // }

  String stageToStatusMessage(String stage) {
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
}

