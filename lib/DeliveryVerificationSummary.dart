import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_assignment/AppColors.dart';
import 'package:mobile_assignment/models/Delivery.dart';
import 'package:mobile_assignment/service/DeliveryService.dart';

class VerificationSummary extends StatelessWidget {
  final String deliveryId;
  bool showingPickup = true;
  late Future<Delivery> future;

  Future<Delivery> fetchDelivery(deliveryId) async {
    return await DeliveryService().fetchDeliveryDetail(deliveryId);
  }

  VerificationSummary({
    super.key,
    required this.deliveryId,
    this.showingPickup = true,
  });

  @override
  Widget build(BuildContext context) {
    future = fetchDelivery(deliveryId);
    return FutureBuilder<Delivery>(
      future: future, // 👈 call your service
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Delivery Verified")),
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("No delivery details found")),
          );
        }

        final delivery = snapshot.data!;
        final stageName = showingPickup ? "Pickup" : "Dropoff";

// Pick the correct verification object
        final verification = showingPickup
            ? delivery.verification?.pickup
            : delivery.verification?.dropoff;

        final recipientName = verification?.recipientName ?? "Not provided";
        final employeeId = verification?.verifiedById ?? "Not provided";
        final verifiedByName = verification?.verifiedByName ?? "Not provided";
        final verifiedBy = verification?.verifiedBy ?? "Not provided";
        final verifiedAt = verification?.verifiedAt?.toLocal().toString() ?? "Not provided";

// Normalize proof attachments into URLs
        final proofUrls = verification?.attachments
            .map((a) => a.downloadUrl)
            .where((url) => url.isNotEmpty)
            .toList() ??
            [];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Delivery Verified"),
            backgroundColor: AppColors.accentColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Delivery Verified Successfully!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ Core info
                _buildInfoRow("Delivery ID", delivery.deliveryId ?? "Unknown"),
                _buildInfoRow("Stage", stageName),
                _buildInfoRow("Recipient Name", recipientName),
                _buildInfoRow("Employee ID", employeeId),
                _buildInfoRow("Verified By", verifiedBy),
                _buildInfoRow("Verified By Name", verifiedByName),
                _buildInfoRow("Verified At", verifiedAt),

                const SizedBox(height: 20),

                if (proofUrls.isNotEmpty) ...[
                  const Text(
                    "Proof of Delivery:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: proofUrls.map((url) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.network(
                            url,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                // ✅ Back button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      context.go('/home');
                    },
                    child: const Text(
                      "Back to Dashboard",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
