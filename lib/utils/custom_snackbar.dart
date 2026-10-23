import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

/// Centralized SnackBar Utility for SmartAIG Admins App
/// Provides consistent Green for Success, Red for Error, and Blue for Info across all screens.
class CustomSnackBar {
  static const Color successColor = AppColors.buttonColor; // Colors.green
  static const Color errorColor = Colors.red;
  static const Color infoColor = Color(0xFF0038A8);
  static const Color textColor = Colors.white;

  /// Show Green Success SnackBar
  static void showSuccess(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: successColor,
      colorText: textColor,
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: textColor,
        size: 24,
      ),
      shouldIconPulse: true,
      borderRadius: AppColors.buttonRadius,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration,
      titleText: Text(
        title,
        style: const TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Helper to convert technical exceptions into user-friendly messages
  static String sanitizeErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('clientexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('no address associated') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('network is unreachable') ||
        lower.contains('software caused connection abort') ||
        lower.contains('timeoutexception') ||
        lower.contains('handshakeexception') ||
        lower.contains('connection closed') ||
        lower.contains('errno =') ||
        lower.contains('os error')) {
      return "Please check your internet connection and try again.";
    }
    
    // Clean up generic prefixes
    String cleaned = message;
    if (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.replaceFirst('Exception: ', '');
    }
    if (cleaned.startsWith('Error occurred: ')) {
      cleaned = cleaned.replaceFirst('Error occurred: ', '');
    }
    return cleaned;
  }

  /// Show Red Error SnackBar
  static void showError(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 4),
  }) {
    final String cleanMessage = sanitizeErrorMessage(message);
    final bool isNetworkIssue = cleanMessage == "Please check your internet connection and try again.";
    final String cleanTitle = isNetworkIssue && (title == "Error" || title.toLowerCase().contains("error"))
        ? "No Internet Connection"
        : title;

    Get.closeCurrentSnackbar();
    Get.snackbar(
      cleanTitle,
      cleanMessage,
      snackPosition: snackPosition,
      backgroundColor: errorColor,
      colorText: textColor,
      icon: Icon(
        isNetworkIssue ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
        color: textColor,
        size: 24,
      ),
      shouldIconPulse: true,
      borderRadius: AppColors.buttonRadius,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration,
      titleText: Text(
        cleanTitle,
        style: const TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        cleanMessage,
        style: const TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Show Blue Info SnackBar
  static void showInfo(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: infoColor,
      colorText: textColor,
      icon: const Icon(
        Icons.info_outline_rounded,
        color: textColor,
        size: 24,
      ),
      shouldIconPulse: true,
      borderRadius: AppColors.buttonRadius,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration,
      titleText: Text(
        title,
        style: const TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Show Amber Warning SnackBar
  static void showWarning(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: const Color(0xFFF59E0B),
      colorText: textColor,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: textColor,
        size: 24,
      ),
      shouldIconPulse: true,
      borderRadius: AppColors.buttonRadius,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration,
      titleText: Text(
        title,
        style: const TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

