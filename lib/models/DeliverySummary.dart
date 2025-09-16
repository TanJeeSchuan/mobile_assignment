
class DeliverySummary {
  final String orderId;
  final String deliverBy;
  final int weight;
  final String status;
  final String source;
  final String destination;

  DeliverySummary({
    required this.orderId,
    required this.deliverBy,
    required this.weight,
    required this.status,
    required this.source,
    required this.destination
  });

  factory DeliverySummary.fromJson(Map<String, dynamic> json){
    return DeliverySummary(
      orderId: json['deliveryId'] ?? "",
      deliverBy: json['deliverBy'] ?? "",
      weight: json['weight'] ?? "",
      status: json['status'] ?? "Unknown",
      source: json['source'] ?? "Unknown",
      destination: json['destination'] ?? "Unknown",
    );
  }
}