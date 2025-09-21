import 'package:http/http.dart' as http;


class VerificationService {
  final String baseUrl = "https://us-central1-mobile-assignment-f9fab.cloudfunctions.net";

  Future<void> verifyDelivery(String deliveryId,
      String stageName,
      List<String> urls,
      String uploaderId,
      String uploaderName,
      String recipientId,
      String recipientName
      ) async {
    // build API query
    // final query = "$baseUrl/verify_delivery?deliveryId=$deliveryId&stage=$stageName&fileUrl=${urls.join(",")}&uploadedBy=$uploaderName";
    // // final response = await http.get(Uri.parse(query));
    final response = await http.post(Uri.parse("$baseUrl/register_verification_file_upload?"
        "deliveryId=$deliveryId"
        "&stage=$stageName"
        "&fileUrl=${urls.join(",")}"
        "&uploadedById=$uploaderId"
        "&uploadedByName=$uploaderName"
        "&recipientId=$recipientId"
        "&recipientName=$recipientName"));


    if (response.statusCode == 200) {
      print("Delivery verified successfully");
    } else {
      print("Failed to verify delivery" + response.body);
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