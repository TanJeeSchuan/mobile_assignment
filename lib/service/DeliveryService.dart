import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_assignment/models/OrderSummary.dart';

class DeliveryService {
  final String baseUrl = "https://us-central1-mobile-assignment-f9fab.cloudfunctions.net";

  Future<List<OrderSummary>> fetchDeliveries() async {
    final response = await http.get(Uri.parse("$baseUrl/get_delivery_summaries?top=5"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      // Extract the deliveries array
      final List<dynamic> deliveriesJson = decoded["deliveries"];

      return deliveriesJson
          .map((e) => OrderSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception("Failed to load deliveries");
    }
  }


}