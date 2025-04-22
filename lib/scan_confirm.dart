import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_tracker_app/firebase_service.dart';

class ScanConfirmationScreen extends StatefulWidget {
  @override
  _ScanConfirmationScreenState createState() => _ScanConfirmationScreenState();
}

class _ScanConfirmationScreenState extends State<ScanConfirmationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  late String _qrId;
  bool _isScanned = false;
  DateTime? _scannedAt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _qrId = ModalRoute.of(context)!.settings.arguments as String;
    _listenForScan();
    _checkInitialStatus();
  }

  void _listenForScan() {
    _firebaseService.getQRScanStatus(_qrId).listen((isScanned) {
      if (isScanned && !_isScanned) {
        setState(() => _isScanned = true);
      }
    });
  }

  Future<void> _checkInitialStatus() async {
    final snapshot = await db.child('qrcodes/$_qrId').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _isScanned = data['scanned'] ?? false;
        if (data['scannedAt'] != null) {
          _scannedAt = DateTime.fromMillisecondsSinceEpoch(data['scannedAt']);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Confirmation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isScanned ? Icons.check_circle : Icons.timer,
                    color: _isScanned ? Colors.green : Colors.orange,
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    _isScanned ? 'QR Code Scanned!' : 'Waiting for scan...',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('QR ID: $_qrId', style: TextStyle(fontSize: 16)),
                  if (_isScanned && _scannedAt != null) ...[
                    SizedBox(height: 20),
                    Text(
                      'Scanned at: ${_scannedAt!.toLocal()}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
