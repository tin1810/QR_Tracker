import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGenerator extends StatelessWidget {
  final String uniqueId = "uniqueQRCode123"; // Example unique ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Code Generator")),
      body: Center(
        child: QrImageView(
          data:
              "https://tin1810.github.io/QR_URL/QR%20Tracker.html", // Custom URL with ID
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
