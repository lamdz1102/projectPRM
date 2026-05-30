import 'package:flutter/material.dart';
import ''
    'screens/splash_screen.dart';

void main() {
  runApp(const PiggyBankApp());
}

class PiggyBankApp extends StatelessWidget {
  const PiggyBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piggy Bank App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDF7FA),
      ),
      home: const SplashScreen(),
    );
  }
}