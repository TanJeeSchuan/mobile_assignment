import 'dart:convert';

import 'package:http/http.dart' as http;


class VerificationService {
  final String baseUrl = "https://us-central1-mobile-assignment-f9fab.cloudfunctions.net";


  Future<void> verifyDelivery(
      String deliveryId,
      String stageName,
      List<String> urls,
      String uploaderId,
      String uploaderName,
      String recipientId,
      String recipientName,
      ) async {
    // Encode URLs as JSON array, then URL-encode the JSON string
    final encodedUrls = Uri.encodeQueryComponent(jsonEncode(urls));

    final uri = Uri.parse(
      "$baseUrl/register_verification_file_upload"
          "?deliveryId=$deliveryId"
          "&stage=$stageName"
          "&fileUrl=$encodedUrls"
          "&uploadedById=$uploaderId"
          "&uploadedByName=${Uri.encodeComponent(uploaderName)}"
          "&recipientId=$recipientId"
          "&recipientName=${Uri.encodeComponent(recipientName)}",
    );

    final response = await http.post(uri);

    print("Sent: ${jsonEncode(urls)} to API");

    if (response.statusCode == 200) {
      print("Delivery verified successfully");
    } else {
      print("Failed to verify delivery: ${response.body}");
    }
  }

  Future<void> verifyPickup(
      String deliveryId,
      String qrString,
      String uploaderId,
      String uploaderName,) async {

    final response = await http.post(Uri.parse("$baseUrl/verify_pickup?"
        "deliveryId=$deliveryId"
        "&uploadedById=$uploaderId"
        "&uploadedByName=$uploaderName"
        "&qrString=$qrString"));

    if (response.statusCode == 200) {
      print("Pickup verified successfully");
    } else {
      print("Failed to verify pickup" + response.body);
    }
  }
}