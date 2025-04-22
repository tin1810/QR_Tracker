import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_tracker_app/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? _currentQR;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateNewQR();
  }

  Future<void> _generateNewQR() async {
    setState(() => _isLoading = true);
    try {
      final qrData = await _firebaseService.generateQRCode();
      setState(() {
        _currentQR = qrData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating QR: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isScanned = _currentQR != null && _currentQR!['scanned'] == true;
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _currentQR == null
                ? Text('No QR generated')
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: QrImageView(
                            data: _currentQR!['qrUrl'],
                            version: QrVersions.auto,
                            size: 200,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'QR ID: ${_currentQR!['id']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh),
                            label: Text('New QR'),
                            onPressed: _generateNewQR,
                          ),
                          SizedBox(width: 20),
                          StreamBuilder<bool>(
                            stream: _firebaseService
                                .getQRScanStatus(_currentQR!['id']),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error loading status');
                              }

                              final isScanned = snapshot.data ?? false;
                              return Text(
                                isScanned
                                    ? '✅ Scanned'
                                    : '🕒 Waiting for scan...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isScanned ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: Icon(Icons.share),
                        label: Text('Share QR Code'),
                        onPressed: () => _shareQR(_currentQR!['qrUrl']),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _checkScanStatus() async {
    if (_currentQR == null) return;

    final isScanned = await _firebaseService.isQRScanned(_currentQR!['id']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Status'),
        content: Text(isScanned
            ? '✅ This QR code has been scanned!'
            : '🕒 This QR code has not been scanned yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareQR(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How It Works'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Generate a new QR code'),
              Text('2. Share it with anyone'),
              Text('3. They can scan it with any device camera'),
              Text('4. Check back here to see if it was scanned'),
              SizedBox(height: 20),
              Text('The QR code links to:'),
              Text('https://tin1810.github.io/QR_URL/',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got It'),
          ),
        ],
      ),
    );
  }
}
