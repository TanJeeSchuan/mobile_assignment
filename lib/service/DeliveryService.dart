import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_assignment/DeliveryDetail.dart';
import 'package:mobile_assignment/models/DeliverySummary.dart';

import '../models/Delivery.dart';

class DeliveryService {
  final String baseUrl = "https://us-central1-mobile-assignment-f9fab.cloudfunctions.net";

  Future<List<DeliverySummary>> fetchDeliveries() async {
    final response = await http.get(Uri.parse("$baseUrl/get_delivery_summaries?top=20"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      // Extract the deliveries array
      final List<dynamic> deliveriesJson = decoded["deliveries"];

      return deliveriesJson
          .map((e) => DeliverySummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception("Failed to load deliveries");
    }
  }

  Future<Delivery> fetchDeliveryDetail(String deliveryId) async {
    final response = await http.get(Uri.parse("$baseUrl/get_delivery_detailed_by_id?deliveryId=$deliveryId"));

    // print(deliveryId);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return Delivery.fromJson(decoded);
    } else {
      throw Exception("Failed to load delivery detail Code: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> fetchDeliveryTypeCount() async {
    final response = await http.get(Uri.parse("$baseUrl/get_delivery_status_summary"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return decoded;
    } else {
      throw Exception("Failed to load delivery detail Code: ${response.statusCode}");
    }
  }
}