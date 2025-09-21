import 'dart:io';  // For File
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';  // For Firestore
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadProofFile(String deliveryId, String staffID, File file) async {
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('proofImage/$deliveryId/${DateTime.now().millisecondsSinceEpoch}.jpg');

  try {
    await storageRef.putFile(
      file,
      SettableMetadata(
        customMetadata: {
          'deliveryId': deliveryId,
          'uploadedBy': staffID,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );

    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    // debugPrint('Error uploading proof file: $e');
    rethrow;
  }
}


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

Future<String> uploadSignatureFile(String deliveryId, String staffID, String stageName, Uint8List signature) async {
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('signatures/$deliveryId/$stageName/${DateTime.now().millisecondsSinceEpoch}.png');

  await storageRef.putData(
    signature,
    SettableMetadata(
      contentType: 'image/png', // ensure PNG is set
      customMetadata: {
        'deliveryId': deliveryId,
        'uploadedBy': staffID,
        'stage': stageName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ),
  );

  final downloadUrl = await storageRef.getDownloadURL();

  return downloadUrl;
}
