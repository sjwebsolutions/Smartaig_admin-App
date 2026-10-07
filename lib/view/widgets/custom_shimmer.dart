import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final ShapeBorder shapeBorder;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final Widget? child;

  /// Default premium gray color palette for modern skeletons
  static const Color defaultBaseColor = Color(0xFFE2E8F0); // Sleek modern slate-gray
  static const Color defaultHighlightColor = Color(0xFFF8FAFC); // Glossy smooth highlight

  /// Rectangular shimmer with customizable rounded corners
  const CustomShimmer.rectangular({
    super.key,
    this.width = double.infinity,
    required double this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1400),
  }) : child = null;

  /// Circular shimmer for avatars, icons, badges
  const CustomShimmer.circular({
    super.key,
    required double this.width,
    required double this.height,
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1400),
  })  : shapeBorder = const CircleBorder(),
        child = null;

  /// Card shimmer skeleton wrapper
  const CustomShimmer.card({
    super.key,
    this.width = double.infinity,
    this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    this.margin,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1400),
    this.child,
  });

  /// Synchronized shimmer wrapper to animate any composite child widget
  const CustomShimmer.fromColors({
    super.key,
    required Widget this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1400),
  })  : width = null,
        height = null,
        margin = null,
        shapeBorder = const RoundedRectangleBorder();

  @override
  Widget build(BuildContext context) {
    final effectiveBase = baseColor ?? defaultBaseColor;
    final effectiveHighlight = highlightColor ?? defaultHighlightColor;

    if (child != null) {
      return Shimmer.fromColors(
        baseColor: effectiveBase,
        highlightColor: effectiveHighlight,
        period: period,
        child: child!,
      );
    }

    return Shimmer.fromColors(
      baseColor: effectiveBase,
      highlightColor: effectiveHighlight,
      period: period,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: ShapeDecoration(
          color: effectiveBase,
          shape: shapeBorder,
        ),
      ),
    );
  }
}


