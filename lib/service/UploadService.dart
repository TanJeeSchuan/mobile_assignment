import 'dart:io';  // For File
import 'package:cloud_firestore/cloud_firestore.dart';  // For Firestore
import 'package:firebase_storage/firebase_storage.dart';

Future<void> uploadProofFile(String deliveryId, String staffID, String stageName, File file) async {
  // 1. Create a reference in Firebase Storage
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('proofImage/$deliveryId/pickup/${DateTime.now().millisecondsSinceEpoch}.jpg');

  // 2. Upload the file
  await storageRef.putFile(
    file,
    SettableMetadata(
      customMetadata: {
        'deliveryId': deliveryId,
        'uploadedBy': staffID,
        'stage': stageName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ),
  );

  // 3. Get download URL
  // final downloadUrl = await storageRef.getDownloadURL();

  // 4. Save a record in Firestore for tracking
  // await FirebaseFirestore.instance
  //     .collection('deliveries')
  //     .doc(deliveryId)
  //     .update({
  //   'verification.pickup.attachments': FieldValue.arrayUnion([
  //     {
  //       'description': 'Proof of pickup',
  //       'path': storageRef.fullPath,
  //       'downloadUrl': downloadUrl,
  //       'uploadedBy': 'driver_1234',
  //       'uploadedAt': DateTime.now().toIso8601String(),
  //     }
  //   ]),
  // });
}
