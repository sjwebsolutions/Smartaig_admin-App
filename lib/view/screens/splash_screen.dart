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
      // 1. Initialize Firebase
      await Firebase.initializeApp();

      // 2. Initialize Analytics & Crashlytics
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // 3. Initialize Notification Service
      try {
        await Get.putAsync(() => NotificationService().init());
      } catch (e) {
        debugPrint("Notification init failed, continuing: $e");
      }
    } catch (e) {
      debugPrint("Core initialization error: $e");
      // Continue anyway to try and show at least the login/main screen
    } finally {
      // Check Auth status regardless of init success/fail
      _checkAuthStatus();
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      // Ensure splash is visible for at least 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      if (token != null && token.isNotEmpty && token != 'null') {
        Get.offAll(() => const MainScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    } catch (e) {
      debugPrint("Auth check error: $e");
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      "assets/images/splash_logo.png",
                      width: 150,
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "SMART AIG ADMIN APP",
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xFF0038A8),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF0038A8).withOpacity(0.2),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "Administrative Informative Group",
                            style: TextStyle(
                              fontSize: 9,
                              color: const Color(0xFF0038A8).withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF0038A8).withOpacity(0.2),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          minHeight: 5,
                          backgroundColor: Color(0xFFF5F5F5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF0038A8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
