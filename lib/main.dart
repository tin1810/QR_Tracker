import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_tracker_app/firebase_service.dart';
import 'package:qr_tracker_app/home_screen.dart';
import 'package:qr_tracker_app/scan_confirm.dart';
import 'package:uni_links/uni_links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseService.initDynamicLinks();
  await initUniLinks(); // Initialize uni_links for deep linking
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      routes: {
        '/scan-confirmed': (context) => ScanConfirmationScreen(),
      },
      navigatorKey: navigatorKey,
    );
  }
}

// Global navigator key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Handle incoming links
Future<void> initUniLinks() async {
  try {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(Uri.parse(initialLink));
    }

    linkStream.listen((String? link) {
      if (link != null) _handleDeepLink(Uri.parse(link));
    });
  } catch (e) {
    print('Error initializing uni_links: $e');
  }
}

void _handleDeepLink(Uri uri) {
  final qrId = uri.queryParameters['id'];
  if (qrId != null) {
    navigatorKey.currentState?.pushNamed(
      '/scan-confirmed',
      arguments: qrId,
    );
  }
}
