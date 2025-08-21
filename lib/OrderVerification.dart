import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Delivery Confirmation',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const DeliveryConfirmation(),
//     );
//   }
// }

class DeliveryConfirmation extends StatefulWidget {
  const DeliveryConfirmation({Key? key}) : super(key: key);

  @override
  State<DeliveryConfirmation> createState() => _DeliveryConfirmationState();
}

class _DeliveryConfirmationState extends State<DeliveryConfirmation> {
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.blue,
  );

  Uint8List? _savedSignature;
  Uint8List? _backupSignature;
  bool _isEditing = false;

  final List<File> _proofFiles = [];

  /// Start editing
  void _startEditing() {
    setState(() {
      _isEditing = true;
      _backupSignature = _savedSignature; // keep old one
      _signatureController.clear();
    });
  }

  /// Cancel → restore old state
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _savedSignature = _backupSignature;
      _signatureController.clear();
    });
  }

  /// Save signature
  Future<void> _saveSignature() async {
    final signature = await _signatureController.toPngBytes();
    setState(() {
      _isEditing = false;
      _savedSignature = signature; // can be null = blank
    });
  }

  /// Redo inside pad
  void _redoSignature() {
    _signatureController.clear();
  }

  /// Clear after saved
  void _clearSignature() {
    setState(() {
      _savedSignature = null;
    });
  }

  /// Pick proof of delivery (photo/video)
  Future<void> _pickProof() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _proofFiles.add(File(file.path));
      });
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _recipientNameController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.description_outlined,
                color: Colors.blue, size: 22),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Delivery Confirmation",
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                Text("Order #123456 (Batu Caves → Sentul)",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipient Info
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person_outline,
                            size: 20, color: Colors.black54),
                        SizedBox(width: 6),
                        Text("Recipient Information",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: _recipientNameController,
                      decoration: const InputDecoration(
                        labelText: "Recipient Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _employeeIdController,
                      decoration: const InputDecoration(
                        labelText: "Employee ID",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Icon(Icons.edit_outlined,
                            size: 20, color: Colors.black54),
                        SizedBox(width: 6),
                        Text("Signature",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Signature Box
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          if (_isEditing)
                            Signature(
                              controller: _signatureController,
                              backgroundColor: Colors.white,
                            )
                          else if (_savedSignature != null)
                            Image.memory(_savedSignature!)
                          else
                            const Center(child: Text("No signature")),

                          if (_isEditing)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: IconButton(
                                icon: const Icon(Icons.refresh,
                                    color: Colors.grey),
                                onPressed: _redoSignature,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Signature Buttons
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _cancelEditing,
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _saveSignature,
                              child: const Text("Save"),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_savedSignature != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _startEditing,
                              child: const Text("Edit"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _clearSignature,
                              child: const Text("Clear"),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _startEditing,
                          child: const Text("Edit"),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: const [
                Icon(Icons.cloud_upload_outlined,
                    size: 20, color: Colors.black54),
                SizedBox(width: 6),
                Text("Proof Of Delivery",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),

            // Upload box
            GestureDetector(
              onTap: _pickProof,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload,
                          size: 40, color: Colors.blueGrey),
                      SizedBox(height: 8),
                      Text("Upload Proof Of Delivery"),
                      Text("Photos, Videos, up to 50MB",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Preview selected files
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _proofFiles.length,
                      (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: FileImage(_proofFiles[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Order Completed")),
                  );
                },
                child: const Text("Order Complete",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
