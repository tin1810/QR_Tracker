import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ScanHandlerScreen extends StatefulWidget {
  final String sessionId;

  const ScanHandlerScreen({Key? key, required this.sessionId})
      : super(key: key);

  @override
  State<ScanHandlerScreen> createState() => _ScanHandlerScreenState();
}

class _ScanHandlerScreenState extends State<ScanHandlerScreen> {
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _markAsScanned();
  }

  Future<void> _markAsScanned() async {
    final ref =
        FirebaseDatabase.instance.ref("qr_sessions/${widget.sessionId}");

    await ref.set({
      "scanned": true,
      "timestamp": DateTime.now().toIso8601String(),
    });

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Result")),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 20),
                  Text("QR Code Scanned Successfully"),
                ],
              ),
      ),
    );
  }
}
