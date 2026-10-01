import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Graceful fallback during local development when Firebase config files are pending
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(
    const ProviderScope(
      child: ClientTrackApp(),
    ),
  );
}
