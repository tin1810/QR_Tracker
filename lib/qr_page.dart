import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String? sessionId;
  DatabaseReference? sessionRef;

  @override
  void initState() {
    super.initState();
    _generateSession();
  }

  // Future<void> _generateSession() async {
  //   final id = Uuid().v4();
  //   final ref = FirebaseDatabase.instance.ref("qr_sessions/$id");
  //   await ref.set({
  //     "scanned": true,
  //     "timestamp": DateTime.now().toIso8601String(),
  //   });
  //   setState(() {
  //     sessionId = id;
  //     sessionRef = ref;
  //   });
  // }

  // Stream<bool> _listenForScan() {
  //   return sessionRef!
  //       .child("scanned")
  //       .onValue
  //       .map((event) => event.snapshot.value == true);
  // }
  Future<void> _generateSession() async {
    final id = Uuid().v4(); // this is your qrId
    final ref = FirebaseDatabase.instance.ref("qr_sessions/$id");

    await ref.set({
      "scanned": false, // default state before scan
      "qrId": id, // unique ID of the QR
      "userId": "user123", // you can pass dynamic user data too
      "timestamp": DateTime.now().toIso8601String(),
    });

    setState(() {
      sessionId = id;
      sessionRef = ref;
    });
  }

  Stream<bool> _listenForScan() {
    if (sessionRef == null) return const Stream.empty();

    return sessionRef!
        .child("scanned")
        .onValue
        .map((event) => event.snapshot.value == true);
  }

  @override
  Widget build(BuildContext context) {
    if (sessionId == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Generating...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Your QR Code")),
      body: StreamBuilder<bool>(
        stream: _listenForScan(),
        builder: (context, snapshot) {
          final isScanned = snapshot.data == true;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show QR code only if it hasn't been scanned yet
                if (!isScanned) ...[
                  QrImageView(
                    data: sessionId!,
                    size: 250,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Session ID:\n$sessionId",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "⏳ Waiting for scan...",
                    style: TextStyle(fontSize: 16),
                  ),
                ] else ...[
                  Text(
                    "QR ID:\n$sessionId",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "✅ QR Code has been scanned!",
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
