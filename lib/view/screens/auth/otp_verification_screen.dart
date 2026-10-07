import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/auth_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  final AuthController _authController = Get.find<AuthController>();

  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 120);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void _resendOtp() {
    _startTimer();
    _authController.sendOtp(_authController.phoneNumber.value);
  }

  void _handleVerifyOtp() {
    _authController.verifyOtp(_otpController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.screenDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: AppColors.appBarToolbarHeight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const CustomBackButton(),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 30.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: AppColors.cardBorderRadius,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Icon
                    const Text(
                      "Verify OTP",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    "A 6 digit OTP was sent to your\nwhatsapp:\n${widget.phoneNumber}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OTP Input Fields
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _buildOtpBox(index)),
                      ),
                      Positioned.fill(
                        child: TextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          autofocus: true,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: const TextStyle(
                            color: Colors.transparent,
                            fontSize: 1,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            setState(() {}); // Rebuild to update visual boxes
                            if (value.length == 6) {
                              _otpFocusNode.unfocus();
                              _handleVerifyOtp();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Color(0xFF1E293B),
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: "OTP expires in "),
                            TextSpan(
                              text: _formatTime(_secondsRemaining),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: _secondsRemaining == 0 ? _resendOtp : null,
                    child: Text(
                      "Resend OTP via WhatsApp",
                      style: TextStyle(
                        color: _secondsRemaining == 0
                            ? const Color(0xFF1E293B)
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Loading Indicator during verification
                  Obx(
                    () => _authController.isLoading.value
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
      ) );
  }

  Widget _buildOtpBox(int index) {
    String text = _otpController.text;
    String digit = "";
    if (index < text.length) {
      digit = text[index];
    }

    // Highlight the box currently being edited (or the last one if full)
    bool isFocused = _otpFocusNode.hasFocus &&
        (index == text.length || (index == 5 && text.length == 6));

    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: 68, // Increased height
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC), // Brighter background
          borderRadius: BorderRadius.circular(15), // Smoother radius
          border: Border.all(
            color: isFocused ? const Color(0xFF0038A8) : const Color(0xFFE2E8F0),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 28, // Even larger font
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }
}
