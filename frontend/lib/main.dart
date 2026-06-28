import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Bắt các lỗi xảy ra trong Flutter framework.
  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Bắt các lỗi bất đồng bộ không được Flutter xử lý.
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: true,
    );

    return true;
  };

  // Khởi tạo notification như code cũ.
  await NotificationService.instance.init();

  runApp(const PiggyBankApp());
}

class PiggyBankApp extends StatelessWidget {
  const PiggyBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piggy Bank App',
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.instance.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFD7FA),
      ),
      home: const SplashScreen(),
    );
  }
}