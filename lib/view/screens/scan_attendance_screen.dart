import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/qr_attendance_controller.dart';

class ScanAttendanceScreen extends StatefulWidget {
  const ScanAttendanceScreen({super.key});

  @override
  State<ScanAttendanceScreen> createState() => _ScanAttendanceScreenState();
}

class _ScanAttendanceScreenState extends State<ScanAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final QrAttendanceController _controller;
  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  bool _isScanning = true;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(QrAttendanceController());

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _controller.isScanning.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        setState(() {
          _isScanning = false;
        });

        final result = await _controller.submitQrScan(rawValue.trim());

        final student = result.data?.student;
        final studentName = student?.studentName;
        final className = student?.className;
        final sectionName = student?.sectionName;

        String studentInfo = "";
        if (studentName != null && studentName.isNotEmpty) {
          studentInfo = "$studentName (${className ?? ''}${sectionName != null && sectionName.isNotEmpty ? '-$sectionName' : ''})";
        }

        if (result.alreadyMarked) {
          final msg = studentInfo.isNotEmpty
              ? "$studentInfo: ${result.message ?? 'Attendance already marked for today.'}"
              : (result.message ?? "Attendance already marked for today.");
          CustomSnackBar.showWarning("Already Marked", msg);
        } else if (result.success) {
          final msg = studentInfo.isNotEmpty
              ? "$studentInfo - Marked Present Successfully"
              : (result.message ?? "Attendance marked successfully");
          CustomSnackBar.showSuccess("Success", msg);
        } else {
          final msg = result.message ?? "Failed to mark attendance.";
          CustomSnackBar.showError("Scan Failed", msg);
        }

        // Debounce delay to prevent duplicate scanning before moving to next student
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.screenDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: AppColors.appBarToolbarHeight,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: AppColors.appBarCenterTitle,
            leading: CustomBackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text(
              "SCAN ATTENDANCE",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Align(
            alignment: const Alignment(0, -0.35),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // QR Scanner Container (300x300)
                  Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. Camera Viewport
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: _onDetect,
                        ),

                        // 2. Translucent Scrim Cutout & Animated Laser Overlay
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _ProfessionalScannerPainter(
                                animationValue: _laserAnimation.value,
                                cutoutSize: const Size(205, 205),
                                cornerRadius: 18.0,
                                cornerLength: 24.0,
                                cornerWidth: 4.0,
                                accentColor: const Color(0xFF0284C7),
                                scrimColor: Colors.black.withValues(alpha: 0.52),
                              ),
                            );
                          },
                        ),

                        // 3. Floating Torch / Flash Quick Button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _scannerController.toggleTorch();
                                setState(() {
                                  _isTorchOn = !_isTorchOn;
                                });
                              },
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _isTorchOn
                                      ? const Color(0xFFFACC15) // Bright Yellow when ON
                                      : const Color(0xFFF59E0B), // Amber Yellow when OFF
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isTorchOn
                                          ? const Color(0xFFFACC15).withValues(alpha: 0.6)
                                          : Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 4. Floating Animated Status Pill at Bottom of Scanner
                        Positioned(
                          bottom: 14,
                          left: 16,
                          right: 16,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0284C7),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  const Text(
                                    "Align Student QR in Frame",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 5. Loading Overlay when API is submitting attendance
                        Obx(() {
                          if (_controller.isScanning.value) {
                            return Container(
                              color: Colors.black.withValues(alpha: 0.65),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                    SizedBox(height: 14),
                                    Text(
                                      "Marking Attendance...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cancel Button
                  SizedBox(
                    width: 300,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444), // Red Background
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                      label: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Professional Scanner CustomPainter with Cutout, Corner Brackets, and Animated Laser Beam
class _ProfessionalScannerPainter extends CustomPainter {
  final double animationValue;
  final Size cutoutSize;
  final double cornerRadius;
  final double cornerLength;
  final double cornerWidth;
  final Color accentColor;
  final Color scrimColor;

  _ProfessionalScannerPainter({
    required this.animationValue,
    required this.cutoutSize,
    required this.cornerRadius,
    required this.cornerLength,
    required this.cornerWidth,
    required this.accentColor,
    required this.scrimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double left = (size.width - cutoutSize.width) / 2;
    final double top = (size.height - cutoutSize.height) / 2;
    final Rect cutoutRect = Rect.fromLTWH(left, top, cutoutSize.width, cutoutSize.height);
    final RRect rrect = RRect.fromRectAndRadius(cutoutRect, Radius.circular(cornerRadius));

    // 1. Draw Translucent Scrim with Cutout Hole
    final Path scrimPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    final Paint scrimPaint = Paint()
      ..color = scrimColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(scrimPath, scrimPaint);

    // 2. Draw Subtle Frame Border
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // 3. Draw 4 L-Shaped Corner Brackets
    final Paint cornerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    final double r = cornerRadius;
    final double l = cornerLength;

    // Top-Left Corner
    final Path tl = Path()
      ..moveTo(cutoutRect.left, cutoutRect.top + l)
      ..lineTo(cutoutRect.left, cutoutRect.top + r)
      ..arcToPoint(Offset(cutoutRect.left + r, cutoutRect.top),
          radius: Radius.circular(r))
      ..lineTo(cutoutRect.left + l, cutoutRect.top);
    canvas.drawPath(tl, cornerPaint);

    // Top-Right Corner
    final Path tr = Path()
      ..moveTo(cutoutRect.right - l, cutoutRect.top)
      ..lineTo(cutoutRect.right - r, cutoutRect.top)
      ..arcToPoint(Offset(cutoutRect.right, cutoutRect.top + r),
          radius: Radius.circular(r))
      ..lineTo(cutoutRect.right, cutoutRect.top + l);
    canvas.drawPath(tr, cornerPaint);

    // Bottom-Left Corner
    final Path bl = Path()
      ..moveTo(cutoutRect.left, cutoutRect.bottom - l)
      ..lineTo(cutoutRect.left, cutoutRect.bottom - r)
      ..arcToPoint(Offset(cutoutRect.left + r, cutoutRect.bottom),
          radius: Radius.circular(r))
      ..lineTo(cutoutRect.left + l, cutoutRect.bottom);
    canvas.drawPath(bl, cornerPaint);

    // Bottom-Right Corner
    final Path br = Path()
      ..moveTo(cutoutRect.right - l, cutoutRect.bottom)
      ..lineTo(cutoutRect.right - r, cutoutRect.bottom)
      ..arcToPoint(Offset(cutoutRect.right, cutoutRect.bottom - r),
          radius: Radius.circular(r))
      ..lineTo(cutoutRect.right, cutoutRect.bottom - l);
    canvas.drawPath(br, cornerPaint);

    // 4. Draw Animated Glowing Laser Beam
    final double laserY = cutoutRect.top + 10 + (cutoutRect.height - 20) * animationValue;
    final Rect laserRect = Rect.fromLTWH(
      cutoutRect.left + 12,
      laserY - 1.5,
      cutoutRect.width - 24,
      3.0,
    );

    // Laser Line Gradient
    final Paint laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          accentColor.withValues(alpha: 0.8),
          accentColor,
          accentColor.withValues(alpha: 0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(laserRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(laserRect, const Radius.circular(2)),
      laserPaint,
    );

    // Laser Glow Area
    final Rect glowRect = Rect.fromLTWH(
      cutoutRect.left + 20,
      laserY - 12,
      cutoutRect.width - 40,
      24,
    );
    final Paint glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withValues(alpha: 0.0),
          accentColor.withValues(alpha: 0.2),
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(glowRect);

    canvas.drawRect(glowRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ProfessionalScannerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
