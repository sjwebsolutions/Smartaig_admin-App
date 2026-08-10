import 'dart:async';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';
import 'package:smart_aig_admins_app/view/screens/auth/login_screen.dart';
import 'package:smart_aig_admins_app/view/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Start initialization as soon as SplashScreen is shown
      await Firebase.initializeApp();
      
      // Initialize Analytics
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

      // Initialize Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Initialize Notification Service
      await Get.putAsync(() => NotificationService().init());

      // Check Login Status
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      // Stay on splash screen for at least 2 seconds for branding
      await Future.delayed(const Duration(seconds: 2));

      if (token != null && token.isNotEmpty) {
        Get.offAll(() => const MainScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      debugPrint("Error during initialization: $e");
      // Even if there's an error, try to go to Login screen
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SplashScreen Logo Image
                Image.asset(
                  "assets/images/splash_logo.png",
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Smart AIG Admins App",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0038A8),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 1, color: Colors.grey[400]),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "ONE SCHOOL ONE APP",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Container(width: 40, height: 1, color: Colors.grey[400]),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 50,
            right: 50,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0038A8)),
                    backgroundColor: Color(0xFFE2E8F0),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "AI-Driven Educational Intelligence",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
