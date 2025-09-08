
class OrderSummary {
  final String orderId;
  final String deliverBy;
  final int weight;
  final String status;
  final String source;
  final String destination;

  OrderSummary({
    required this.orderId,
    required this.deliverBy,
    required this.weight,
    required this.status,
    required this.source,
    required this.destination
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json){
    return OrderSummary(
      orderId: json['deliveryId'] ?? "",
      deliverBy: json['deliverBy'] ?? "",
      weight: json['weight'] ?? "",
      status: json['status'] ?? "Unknown",
      source: json['source'] ?? "Unknown",
      destination: json['destination'] ?? "Unknown",
    );
  }


}