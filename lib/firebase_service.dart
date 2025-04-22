import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>> generateQRCode() async {
    final qrId = DateTime.now().millisecondsSinceEpoch.toString();
    final qrUrl = 'https://tin1810.github.io/QR_URL/QR%20Tracker.html?id=$qrId';

    await _db.child('qrcodes/$qrId').set({
      'id': qrId,
      'createdAt': ServerValue.timestamp,
      'qrUrl': qrUrl,
      'scanned': false,
      'scannedAt': null,
      'scannedBy': null,
    });

    return {
      'id': qrId,
      'qrUrl': qrUrl,
    };
  }

  Future<bool> isQRScanned(String qrId) async {
    final snapshot = await _db.child('qrcodes/$qrId/scanned').get();
    return snapshot.value as bool? ?? false;
  }

  Stream<bool> getQRScanStatus(String qrId) {
    return _db
        .child('qrcodes/$qrId/scanned')
        .onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  Future<void> recordScan(String qrId) async {
    await _db.child('qrcodes/$qrId').update({
      'scanned': true,
      'scannedAt': ServerValue.timestamp,
      'scannedBy': 'external_user',
    });
  }

  static Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final uri = dynamicLinkData.link;
      final qrId = uri.queryParameters['id'];
      if (qrId != null) {
        // Handle the QR scan (this will be used in main.dart)
      }
    }).onError((error) {
      print('Dynamic Link error: $error');
    });
  }
}
