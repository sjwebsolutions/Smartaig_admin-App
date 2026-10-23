import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_aig_admins_app/models/admit_card_scan_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/admit_card_scan_controller.dart';

class AdmitCardScanScreen extends StatefulWidget {
  const AdmitCardScanScreen({super.key});

  @override
  State<AdmitCardScanScreen> createState() => _AdmitCardScanScreenState();
}

class _AdmitCardScanScreenState extends State<AdmitCardScanScreen>
    with SingleTickerProviderStateMixin {
  late final AdmitCardScanController _controller;
  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  bool _isScanning = true;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AdmitCardScanController>()
        ? Get.find<AdmitCardScanController>()
        : Get.put(AdmitCardScanController());
    _controller.reset();
    _isScanning = true;
    _isTorchOn = false;

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
    _controller.reset();
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _controller.isLoading.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        setState(() {
          _isScanning = false;
        });

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        print("📸 [QR Scanner] Scanned QR Code: $rawValue");
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        final success = await _controller.verifyAdmitCard(qrCode: rawValue.trim());
        if (!success) {
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
          }
        }
        break;
      }
    }
  }

  void _resumeScanning() {
    _controller.reset();
    setState(() {
      _isScanning = true;
      _isTorchOn = false;
    });
    try {
      _scannerController.start();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasResultOrError = _controller.isSuccess.value ||
          _controller.hasSearched.value ||
          _controller.isLoading.value;

      return PopScope(
        canPop: !hasResultOrError,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _resumeScanning();
        },
        child: Container(
          decoration: AppColors.screenDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              toolbarHeight: AppColors.appBarToolbarHeight,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: AppColors.appBarCenterTitle,
              leading: CustomBackButton(
                onPressed: () {
                  if (hasResultOrError) {
                    _resumeScanning();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              title: const Text(
                "ADMIT CARD SCAN",
                style: AppColors.appBarTitleStyle,
              ),
            ),
            body: () {
              // 1. Loading state after scanning
              if (_controller.isLoading.value) {
                return _buildLoadingView();
              }

              // 2. Verified Result View
              if (_controller.isSuccess.value && _controller.scanResult.value != null) {
                return _buildVerifiedResultView(_controller.scanResult.value!);
              }

              // 3. Error state if scan verification failed
              if (_controller.hasSearched.value && !_controller.isSuccess.value) {
                return _buildErrorView(_controller.message.value);
              }

              // 4. Professional Live Scanner View
              return _buildLiveScannerView();
            }(),
          ),
        ),
      );
    });
  }

  // Professional Live Scanner View (Shifted Higher Up)
  Widget _buildLiveScannerView() {
    return Align(
      alignment: const Alignment(0, -0.45),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Authentic Scanner Container with Laser Animation & Scrim Cutout (300x300)
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.25),
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

                  // 2. Dark Scrim Cutout & Animated Laser Overlay
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
                          accentColor: const Color(0xFF10B981),
                          scrimColor: Colors.black.withValues(alpha: 0.52),
                        ),
                      );
                    },
                  ),

                  // 3. Floating Torch / Flash Quick Button with Yellow Round Background
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
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
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
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              "Align Admit Card QR in Frame",
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
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cancel Button (Same Width as Scanner 300px, Red Background, Radius 10)
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
                    borderRadius: BorderRadius.circular(10), // Radius 10
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
    );
  }

  // Loading View
  Widget _buildLoadingView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: AppColors.cardDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
            SizedBox(height: 18),
            Text(
              "Verifying Admit Card...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Fetching student profile & seating arrangement",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error View
  Widget _buildErrorView(String errorMsg) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: AppColors.cardDecoration(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE4E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFFE11D48),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Verification Failed",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMsg.isNotEmpty ? errorMsg : "Invalid or unrecognized admit card QR code.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _resumeScanning,
                icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                label: const Text(
                  "Scan Again",
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
    );
  }

  // Verified Details View
  Widget _buildVerifiedResultView(AdmitCardScanData data) {
    final student = data.student;
    final admitCard = data.admitCard;
    final seatingPlan = data.seatingPlan;
    final todaySeat = seatingPlan?.todaySeat;
    final feeBalance = data.feeBalance;
    final schedule = data.datesheetSchedule;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20,),
          // Top Action Button: Scan Next Admit Card (Top with upper spacing)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _resumeScanning,
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
              label: const Text(
                "Scan Next Admit Card",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 1. Student Profile Card
          if (student != null) ...[
            _buildStudentProfileCard(student),
            const SizedBox(height: 14),
          ],

          // 2. Today's Seating Arrangement Card (Hero)
          if (todaySeat != null) ...[
            _buildTodaySeatCard(todaySeat),
            const SizedBox(height: 14),
          ],

          // 3. Fee Balance Card
          if (feeBalance != null) ...[
            _buildFeeBalanceCard(feeBalance),
            const SizedBox(height: 14),
          ],

          // 4. Admit Card & Center Info Card
          if (admitCard != null) ...[
            _buildAdmitCardInfoCard(admitCard),
            const SizedBox(height: 14),
          ],

          // 5. Datesheet & Exam Schedule
          if (schedule.isNotEmpty)
            _buildScheduleCard(schedule, seatingPlan?.allSeats ?? []),
        ],
      ),
    );
  }

  // Student Profile Card
  Widget _buildStudentProfileCard(StudentInfo student) {
    return Container(
      decoration: AppColors.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Avatar / Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 65,
                  height: 75,
                  color: const Color(0xFFF1F5F9),
                  child: student.photoUrl != null && student.photoUrl!.isNotEmpty
                      ? Image.network(
                          student.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: Color(0xFF94A3B8),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Student Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            student.studentName ?? "N/A",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (student.status ?? "ACTIVE").toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Class: ${student.classSection ?? student.studentClass ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Exam Roll No: ${student.examRollNo ?? student.rollNo ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem("Father's Name", student.fatherName ?? "N/A"),
              ),
              Expanded(
                child: _buildInfoItem("Mother's Name", student.motherName ?? "N/A"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem("Admission No", student.admissionNumber ?? "N/A"),
              ),
              Expanded(
                child: _buildInfoItem("Student Unique ID", student.studentUniqueId ?? "N/A"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem("DOB", student.formattedDob ?? student.dob ?? "N/A"),
              ),
              Expanded(
                child: _buildInfoItem("Contact", student.fatherMobile ?? student.motherMobile ?? "N/A"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Today's Seat Card
  Widget _buildTodaySeatCard(TodaySeatInfo todaySeat) {
    final bool isAssigned = todaySeat.isAssigned;

    return Container(
      decoration: BoxDecoration(
        color: isAssigned ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAssigned ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_seat_rounded,
                color: isAssigned ? const Color(0xFF059669) : const Color(0xFFD97706),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Today's Exam Seating",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isAssigned ? const Color(0xFF065F46) : const Color(0xFF92400E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAssigned ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAssigned ? "ASSIGNED" : "PENDING",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAssigned ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "${todaySeat.subject ?? 'Exam'} • ${todaySeat.formattedDate ?? todaySeat.examDate ?? ''} (${todaySeat.day ?? ''})",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          if (todaySeat.seatLabel != null && todaySeat.seatLabel!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                todaySeat.seatLabel!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                ),
              ),
            )
          else if (todaySeat.message != null)
            Text(
              todaySeat.message!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
        ],
      ),
    );
  }

  // Fee Balance Card
  Widget _buildFeeBalanceCard(FeeBalanceInfo fee) {
    final bool hasDue = fee.hasDue;

    return Container(
      decoration: AppColors.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasDue ? const Color(0xFFFFE4E6) : const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasDue ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
              color: hasDue ? const Color(0xFFE11D48) : const Color(0xFF059669),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fee Balance Status",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fee.message ?? (hasDue ? "Balance pending" : "All fees cleared"),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            fee.formattedBalance ?? (fee.balanceTillToday != null ? "₹${fee.balanceTillToday}" : "₹0.00"),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: hasDue ? const Color(0xFFE11D48) : const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }

  // Admit Card & Exam Center Info
  Widget _buildAdmitCardInfoCard(AdmitCardInfo card) {
    return Container(
      decoration: AppColors.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assignment_rounded, color: Color(0xFF4F46E5), size: 20),
              SizedBox(width: 8),
              Text(
                "Examination Details",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem("Exam Title", "${card.examTitle ?? 'Exam'} (${card.session ?? ''})"),
          const SizedBox(height: 8),
          _buildInfoItem("Exam Center", card.examCenterName ?? "N/A"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem("Timing", "${card.startTime ?? ''} - ${card.endTime ?? ''}"),
              ),
              Expanded(
                child: _buildInfoItem("Dates", "${card.examStartDate ?? ''} to ${card.examEndDate ?? ''}"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Schedule & Seating Table Card
  Widget _buildScheduleCard(List<DatesheetScheduleItem> schedule, List<SeatItemInfo> allSeats) {
    return Container(
      decoration: AppColors.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_month_rounded, color: Color(0xFF0EA5E9), size: 20),
              SizedBox(width: 8),
              Text(
                "Datesheet & Seating Plan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedule.length,
            separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final item = schedule[index];
              SeatItemInfo? matchingSeat;
              try {
                matchingSeat = allSeats.firstWhere(
                  (s) => s.examDate == item.examDate || s.subject == item.subjectName,
                );
              } catch (_) {
                matchingSeat = null;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.subjectName ?? "Subject",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.subjectCode ?? "",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        "${item.formattedDate ?? item.examDate ?? ''} (${item.day ?? ''}) • ${item.timing ?? ''}",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  if (matchingSeat != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      matchingSeat.seatLabel ?? matchingSeat.message ?? "Seat assigned",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: matchingSeat.isAssigned ? const Color(0xFF059669) : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper info field
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

/// Custom Painter for Professional Scanner Viewfinder & Laser Animation
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

    // 3. Draw 4 L-Shaped Professional Corner Brackets
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

    // Laser Glow Glow Area
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
