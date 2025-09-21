import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_assignment/models/Delivery.dart';
import 'package:mobile_assignment/service/AuthService.dart';
import 'package:mobile_assignment/service/DeliveryService.dart';
import 'package:mobile_assignment/service/UploadService.dart';
import 'package:mobile_assignment/service/VerificationService.dart';
import 'dart:typed_data';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'GeneralWidgets.dart';
import 'signature_input.dart';

class DropoffVerification extends StatefulWidget {
  final String deliveryId;
  DropoffVerification({super.key, required this.deliveryId});

  @override
  State<DropoffVerification> createState() => _DropoffVerificationState();
}

class _DropoffVerificationState extends State<DropoffVerification> {
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();
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

  late DeliveryService _deliveryService;
  late Future<Delivery?> _deliveryFuture;

  @override
  void initState() {
    super.initState();
    _deliveryService = DeliveryService();
    _deliveryFuture = fetchDelivery(widget.deliveryId);

    _recipientNameController.addListener(() => setState(() {}));
    _employeeIdController.addListener(() => setState(() {}));
  }

  Future<Delivery?> fetchDelivery(String deliveryId) async {
    return await _deliveryService.fetchDeliveryDetail(deliveryId);
  }

  bool get _canSubmit {
    return _recipientNameController.text.isNotEmpty &&
        _employeeIdController.text.isNotEmpty &&
        _savedSignature != null &&
        _proofFiles.isNotEmpty &&
        !_isSubmitting;
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _recipientNameController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  /// Signature methods
  Future<void> _startEditing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReceiverSignaturePage()),
    );

    if (result != null && result is Uint8List) {
      setState(() {
        _savedSignature = result;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _savedSignature = _backupSignature;
      _signatureController.clear();
    });
  }

  Future<void> _saveSignature() async {
    final signature = await _signatureController.toPngBytes();
    setState(() {
      _isEditing = false;
      _savedSignature = signature;
    });
  }

  void _redoSignature() {
    _signatureController.clear();
  }

  void _clearSignature() {
    setState(() {
      _savedSignature = null;
    });
  }

  /// Pick proof files
  Future<void> _pickProof() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _proofFiles.add(File(file.path));
      });
    }
  }

  /// Success animation
  Future<void> _showSuccessAnimation() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 80),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Submit confirmation
  Future<void> _submitConfirmation(String deliveryId, String stageName) async {
    setState(() {
      _isSubmitting = true;
    });

    final recipientName = _recipientNameController.text;
    final employeeId = _employeeIdController.text;
    final signature = _savedSignature;
    final proofFiles = _proofFiles;

    if (recipientName.isEmpty ||
        employeeId.isEmpty ||
        signature == null ||
        proofFiles.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Missing Information"),
          content: const Text(
              "❌ All fields are required. Please fill them in before continuing."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ No current user found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    try {
      // Upload proof files sequentially
      List<String> proofUrls = [];
      for (var file in proofFiles) {
        String url = await uploadProofFile(deliveryId, currentUser.staffId, file);
        proofUrls.add(url);
      }

      print(proofUrls);

      // Upload signature
      String signatureUrl = await uploadSignatureFile(
          deliveryId, currentUser.staffId, stageName, signature);

      proofUrls.add(signatureUrl);

      // Verify delivery
      await VerificationService().verifyDelivery(
          deliveryId,
          stageName,
          proofUrls,
          currentUser.staffId,
          currentUser.staffName,
          employeeId,
          recipientName
      );

      //await _showSuccessAnimation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order Completed Successfully")),
      );



    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      return;
    } finally {
      setState(() => _isSubmitting = false);
    }

    // return to dashboard
    if(mounted) {
      context.go("/home/deliveryDetail/$deliveryId/dropoffVerification/verified");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _deliveryFuture,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (asyncSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${asyncSnapshot.error}')),
          );
        }

        final delivery = asyncSnapshot.data;
        if (delivery == null) {
          return const Scaffold(
            body: Center(child: Text('Delivery not found')),
          );
        }

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
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Row(
              children: [
                const Icon(Icons.description_outlined,
                    color: Colors.blue, size: 22),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Delivery Confirmation",
                        style: TextStyle(color: Colors.black, fontSize: 24)),
                    Text("Order #${delivery.deliveryId?.toUpperCase() ?? ''}",
                        style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipient Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 20, color: Colors.black54),
                              SizedBox(width: 6),
                              Text("Recipient Information",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _recipientNameController,
                            decoration: const InputDecoration(
                              labelText: "Recipient Name",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter recipient name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _employeeIdController,
                            decoration: const InputDecoration(
                              labelText: "Employee ID",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter employee ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Signature
                          const Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 20, color: Colors.black54),
                              SizedBox(width: 6),
                              Text("Signature",
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                  // Proof of Delivery
                  const Row(
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 20, color: Colors.black54),
                      SizedBox(width: 6),
                      Text("Proof Of Delivery",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _proofFiles.length,
                            (index) => ImageWithPreview(
                          imageFile: _proofFiles[index],
                          showDeleteButton: true,
                          onDelete: () {
                            setState(() {
                              _proofFiles.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSubmit ? Colors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _canSubmit
                          ? () => _submitConfirmation(
                        delivery.deliveryId.toString(),
                        delivery.getCurrentStage()!,
                      )
                          : null,
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Order Complete",
                          style:
                          TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
