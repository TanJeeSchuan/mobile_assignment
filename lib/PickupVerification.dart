import 'package:flutter/material.dart';
import 'package:mobile_assignment/service/DeliveryService.dart';
import 'package:mobile_assignment/service/VerificationService.dart';

import 'AppColors.dart';
import 'GeneralWidgets.dart';
import 'models/Delivery.dart';



// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Pickup Confirmation',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Roboto',
//       ),
//       home: const PickupConfirmationPage(),
//     );
//   }
// }

class PickupConfirmationPage extends StatefulWidget {
  final String deliveryId; // <-- store the deliveryId

  PickupConfirmationPage({super.key, required this.deliveryId});
  @override
  State<PickupConfirmationPage> createState() => _PickupConfirmationPageState();
}

class _PickupConfirmationPageState extends State<PickupConfirmationPage> {
  bool _verified = false;
  late Future<Delivery?> _deliveryFuture;

  @override initState(){
    super.initState();
    _deliveryFuture = fetchDelivery(widget.deliveryId);
  }

  Future<Delivery?> fetchDelivery(deliveryId) async {
    return await DeliveryService().fetchDeliveryDetail(deliveryId);
  }

  // List<Map<String, dynamic>> _items = delivery.partsListToMap();

  // final List<Map<String, dynamic>> _items = [
  //   {'code': 'MY-PRO-0001', 'name': 'Brake Pads for Proton Saga', 'qty': 12},
  //   {'code': 'MY-PER-0002', 'name': 'Oil Filters for Perodua Myvi', 'qty': 25},
  //   {'code': 'MY-PRO-0003', 'name': 'Air Filters for Proton Persona', 'qty': 18},
  //   {'code': 'MY-PER-0004', 'name': 'Timing Belts for Perodua Axia', 'qty': 10},
  //   {'code': 'MY-PRO-0005', 'name': 'Spark Plugs for Proton Iriz', 'qty': 40},
  //   {'code': 'MY-PER-0006', 'name': 'Shock Absorbers for Perodua Bezza', 'qty': 7},
  // ];

  void _toggleVerified() {
    setState(() => _verified = !_verified);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_verified ? 'Simulated: package scanned' : 'Scan cleared'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  List<Map<String, dynamic>> _items = [];
  void updateItemsList(Delivery delivery){
    _items = delivery.partsListToMap();
    // setState(() {
    //
    // });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 560 ? 540.0 : width - 36.0;

    return FutureBuilder(
      future: fetchDelivery(widget.deliveryId),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (asyncSnapshot.hasError) {
          return Center(
            child: Text('Error: ${asyncSnapshot.error}'),
          );
        }

        final delivery = asyncSnapshot.data;
        if (delivery == null) {
          return Center(
            child: Text('Delivery not found'),
          );
        }

        updateItemsList(delivery);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: back button + title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentColor,//const Color(0xFF00B0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.directions_car_rounded,
                          size: 26, color: AppColors.accentColor,),//const Color(0xFF00B0F0),Color(0xFF69BFE8)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pickup Confirmation",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text("Delivery #${delivery.delivery_id.toString().toUpperCase()}",//123456 (Batu Caves → Sentul)",
                              style: TextStyle(fontSize: 14, color: AppColors.subText)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Card
                  Center(
                    child: Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,//Color.fromRGBO(60, 60, 60, 0.12),
                            offset: Offset(6, 10),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + divider
                            Text("Delivery #${delivery.delivery_id.toString().toUpperCase()}",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),

                            // Status badge
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _verified
                                  ? AppColors.verifiedColor
                                  : AppColors.unverifiedColor,
                                      // ? const Color(0xFFDFF7E4)
                                      // : const Color(0xFFF9D6D6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(_verified ? 'Verified' : 'Unverified',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _verified ? Colors.green[800] : Colors.red[800],
                                    )),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Package Details title
                            const Text("Package Details",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),

                            // Table
                            ItemsTable(items: _items),

                            const SizedBox(height: 18),

                            const Text("Verify Delivery",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),

                            // Scan box (tappable)
                            GestureDetector(
                              onTap: _toggleVerified,
                              child: Container(
                                height: 220,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF9FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 78,
                                        color: Color(0xFF6EADE1),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text("Scan QR Code on package",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Text("Scan in stable, well lit area",
                                        style: TextStyle(
                                            color: AppColors.subText, fontSize: 13)),
                                    const SizedBox(height: 12),
                                    Text(
                                      _verified
                                          ? "Tap to clear scan"
                                          : "Tap to simulate scan",
                                      style: TextStyle(
                                        color: AppColors.subText,//Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // Pickup Verified button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _verified ? () {
                                  performPickupAction(delivery.delivery_id!);
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                                child: const Text("Pickup Verified"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  void performPickupAction(String deliveryId) {
    VerificationService().verifyPickup(deliveryId);
  }
}
