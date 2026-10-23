import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable Custom Circular Back Button
/// Uses CircleAvatar with smooth iOS-style back icon.
class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double radius;
  final double iconSize;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFF1E293B),
    this.radius = 15,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: iconColor,
            size: iconSize,
          ),
          onPressed: onPressed ?? () => Get.back(),
        ),
      ),
    );
  }
}
