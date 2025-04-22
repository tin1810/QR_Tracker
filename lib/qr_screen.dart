import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:firebase_database/firebase_database.dart';

class QRScreen1 extends StatefulWidget {
  const QRScreen1({super.key});

  @override
  State<QRScreen1> createState() => _QRScreen1State();
}

class _QRScreen1State extends State<QRScreen1> {
  String? sessionId;
  DatabaseReference? sessionRef;

  @override
  void initState() {
    super.initState();
    _initDeepLink();
  }

  // Initialize deep link listener
  Future<void> _initDeepLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(Uri.parse(initialLink));
      }

      linkStream.listen((String? link) {
        if (link != null) {
          _handleDeepLink(Uri.parse(link));
        }
      });
    } catch (e) {
      print("Error handling deep link: $e");
    }
  }

  // Handle deep link and mark session as scanned
  void _handleDeepLink(Uri deepLink) async {
    final sessionId = deepLink.queryParameters['sessionId'];
    if (sessionId != null) {
      final ref = FirebaseDatabase.instance.ref("qr_sessions/$sessionId");
      await ref.update({
        "scanned": true,
        "timestamp": DateTime.now().toIso8601String(),
      });
      setState(() {
        this.sessionId = sessionId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Scan Status")),
      body: Center(
        child: Text(sessionId != null
            ? "Session $sessionId scanned!"
            : "Waiting for scan..."),
      ),
    );
  }
}
