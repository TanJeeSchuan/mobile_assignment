import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Signature Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ReceiverSignaturePage(),
    );
  }
}

class ReceiverSignaturePage extends StatefulWidget {
  const ReceiverSignaturePage({super.key});

  @override
  State<ReceiverSignaturePage> createState() => _ReceiverSignaturePageState();
}

class _ReceiverSignaturePageState extends State<ReceiverSignaturePage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.blue,
    exportBackgroundColor: Colors.white,
  );

  Uint8List? _signatureData;

  void _clearSignature() {
    _controller.clear();
  }

  Future<void> _confirmSignature() async {
    if (_controller.isNotEmpty) {
      final signature = await _controller.toPngBytes();
      setState(() {
        _signatureData = signature;
      });
      Navigator.pop(context, _signatureData); // return saved signature
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No signature provided")),
      );
    }
  }

  void _cancelSignature() {
    _controller.clear();
    Navigator.pop(context); // just leave page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receiver Signature Input"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Receiver should sign signature at box below. Select “Confirm” once done",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Signature Box with redo icon
            Stack(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.white,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    onPressed: _clearSignature,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _cancelSignature,
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _confirmSignature,
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
