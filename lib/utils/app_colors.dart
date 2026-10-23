import 'package:flutter/material.dart';
export 'custom_back_button.dart';
export 'custom_snackbar.dart';

/// Centralized Color Palette and Screen Background Configuration
/// Changing colors here will update the background and theme across the entire application.
class AppColors {
  // Screen Background Gradient Colors
  // Change these 3 colors to change the background across all screens in the app!
  static const Color gradientStart = Color(0xFFCBE2FE); // Vibrant Soft Sky Blue
  static const Color gradientMiddle = Color(0xFFE2DCFE); // Smooth Royal Lavender
  static const Color gradientEnd = Color(0xFFFFE2EA); // Warm Glowing Sunset Blush

  // Primary Theme Colors
  static const Color primaryNavy = Color(0xFF132A60);
  static const Color primaryBlue = Color(0xFF0038A8);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentGreen = Colors.green;

  // Text Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textBody = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  // Surface & Border Colors
  static const Color surfaceWhite = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color backgroundLight = Color(0xFFF8F9FE);

  // App-wide Screen Background Gradient
  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment(-0.8, -1.0),
    end: Alignment(0.8, 1.0),
    colors: [
      gradientStart,
      gradientMiddle,
      gradientEnd,
    ],
    stops: [0.0, 0.48, 1.0],
  );

  // App-wide Full Screen Background Decoration
  static const BoxDecoration screenDecoration = BoxDecoration(
    gradient: screenGradient,
  );

  // Centralized Button Styling
  // Changing buttonColor or buttonRadius here updates buttons across the whole app!
  static const Color buttonColor = Colors.green;
  static const Color buttonTextColor = Colors.white;
  static const double buttonRadius = 12.0;
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(12);
  static final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  static ButtonStyle primaryButtonStyle({
    EdgeInsetsGeometry? padding = const EdgeInsets.symmetric(vertical: 14),
    double elevation = 2,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? buttonColor,
      foregroundColor: foregroundColor ?? buttonTextColor,
      padding: padding,
      shape: buttonShape,
      elevation: elevation,
    );
  }

  // Centralized AppBar Styling
  // Changing AppBar properties here will update the AppBar on all screens!
  static const Color appBarTitleColor = Color(0xFF1E293B);
  static const double appBarTitleSize = 18.0;
  static const FontWeight appBarTitleWeight = FontWeight.bold;
  static const bool appBarCenterTitle = true;
  static const double appBarHeight = 56.0;
  static const double appBarToolbarHeight = 56.0;

  static const TextStyle appBarTitleStyle = TextStyle(
    color: appBarTitleColor,
    fontSize: appBarTitleSize,
    fontWeight: appBarTitleWeight,
    letterSpacing: 0.5,
  );

  // Centralized Card & Container Card Styling
  // Changing card properties here will update cards & containers across the entire app!
  static const Color cardColor = Colors.white;
  static const double cardRadius = 12.0;
  static final BorderRadius cardBorderRadius = BorderRadius.circular(12);
  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration cardDecoration({
    Color? color,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: borderRadius ?? cardBorderRadius,
      border: border,
      boxShadow: boxShadow,
      gradient: gradient,
    );
  }
}
