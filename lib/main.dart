import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';

void main() {
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
