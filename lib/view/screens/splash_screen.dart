import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/auth/login_screen.dart';
import 'package:smart_aig_admins_app/view/screens/main_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/dashboard_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _containerController;
  late Animation<Offset> _containerSlide;

  @override
  void initState() {
    super.initState();
    _updateSystemUI();
    _setupAnimation();
    _startAnimation();
    _checkAuthStatus();
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _setupAnimation() {
    _containerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _containerSlide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _containerController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _startAnimation() {
    _containerController.forward();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token != null && token.isNotEmpty && token != 'null') {
        // Pre-initialize DashboardController in background while splash is visible
        if (!Get.isRegistered<DashboardController>()) {
          Get.put(DashboardController());
        }
      }

      // Fast, smooth transition duration
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      if (token != null && token.isNotEmpty && token != 'null') {
        Get.offAll(
          () => const MainScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        Get.offAll(
          () => const LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
      }
    } catch (e) {
      debugPrint("Auth check error: $e");
      if (mounted) {
        Get.offAll(() => const LoginScreen());
      }
    }
  }

  @override
  void dispose() {
    _containerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.screenDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SlideTransition(
                        position: _containerSlide,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/splash_logo.png",
                                width: 180,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Smart AIG - Admins App",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFF132A60),
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Administrative Info Group',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 5.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                    child: Container(
                      width: double.infinity,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 50),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF132A60).withValues(alpha: 0.25),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF132A60).withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Center(
                        child: SizedBox(
                          height: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: LinearProgressIndicator(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              color: const Color(0xFF132A60),
                              backgroundColor: const Color(0xFFE2E8F0),
                            ),
                          ),
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
    );
  }
}
