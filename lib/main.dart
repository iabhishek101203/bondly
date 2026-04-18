import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bondly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', // Assuming default font for now, can be updated
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE94057)),
        useMaterial3: true,
      ),
      home: const LandingScreen(),
    );
  }
}
