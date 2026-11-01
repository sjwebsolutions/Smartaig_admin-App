import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_aig_admins_app/models/event_pass_scan_model.dart';
import 'package:smart_aig_admins_app/models/event_today_scans_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/event_scan_result_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/event_controller.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with SingleTickerProviderStateMixin {
  late final EventController controller;
  late final MobileScannerController _scannerController;
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  final TextEditingController _searchController = TextEditingController();

  bool _isScanningActive = true;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EventController>()
        ? Get.find<EventController>()
        : Get.put(EventController());

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
    _searchController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanningActive || controller.isScanningPass.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        setState(() {
          _isScanningActive = false;
        });

        final result = await controller.scanPass(
          qrPayload: rawValue.trim(),
        );

        if (mounted) {
          Get.to(() => EventScanResultScreen(scanResult: result))?.then((_) {
            if (mounted) {
              setState(() {
                _isScanningActive = true;
              });
            }
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: AppColors.screenDecoration,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              toolbarHeight: AppColors.appBarToolbarHeight,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: AppColors.appBarCenterTitle,
              leading: const CustomBackButton(),
              title: const Text(
                "EVENTS & SCANS",
                style: AppColors.appBarTitleStyle,
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TabBar(
                    isScrollable: false,
                    dividerColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF505AC9),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF505AC9).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded, size: 16),
                            SizedBox(width: 6),
                            Text("Pass Scan"),
                          ],
                        ),
                      ),
                      Tab(
                        height: 38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.badge_outlined, size: 16),
                            SizedBox(width: 6),
                            Text("View Gate Pass"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                _buildPassScanTabContent(),
                _buildViewPassTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= TAB 1: PASS SCAN =================

  Widget _buildPassScanTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Header Text
          const Text(
            "Point camera at the Event Pass QR / Barcode",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Pass scan will be validated automatically upon detection",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 24),

          // Black Scanner Container Box
          Center(
            child: Container(
              height: 340,
              width: 310,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Mobile Scanner Feed
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Camera Permission Needed",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Overlay Frame & Cyan Laser
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ScannerFramePainter(
                          animationValue: _laserAnimation.value,
                          cutoutSize: const Size(220, 220),
                          cornerRadius: 20.0,
                          accentColor: const Color(0xFF00C2FF),
                          scrimColor: Colors.black.withValues(alpha: 0.45),
                        ),
                      );
                    },
                  ),

                  // Flash Torch Toggle
                  Positioned(
                    top: 16,
                    right: 16,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Verifying Loading Overlay
                  Obx(() {
                    if (controller.isScanningPass.value) {
                      return Container(
                        color: Colors.black.withValues(alpha: 0.75),
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
                                "Verifying Pass...",
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
          ),

          const SizedBox(height: 32),

          // Red Cancel Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cancel_rounded, size: 22, color: Colors.white),
              label: const Text(
                "CANCEL",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: VIEW PASS (Get Gate Pass Data View) =================

  Widget _buildViewPassTabContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF132A60),
          ),
        );
      }

      if (controller.hasError.value) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchTodayScans(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Failed to Load Scans",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchTodayScans(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF132A60),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final scans = controller.filteredScans;

      return RefreshIndicator(
        onRefresh: () => controller.fetchTodayScans(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            // 1. Top Summary Banner
            _buildSummaryHeader(),

            const SizedBox(height: 12),

            // 2. Search Bar
            _buildSearchBar(),

            const SizedBox(height: 12),

            // 3. Status Filter Tabs
            _buildFilterChipsSection(),

            const SizedBox(height: 14),

            // 4. Section Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 16,
                    color: Color(0xFF132A60),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "SCAN LOGS",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    "${scans.length} Results",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF132A60),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 5. Scan Cards List
            if (scans.isEmpty)
              _buildEmptyState()
            else
              ...scans.map((item) => _buildScanCard(item)),

            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  // --- Top Summary Section ---
  Widget _buildSummaryHeader() {
    final validScans = controller.totalValidScansToday.value;
    final totalScans = controller.scansList.length;
    final duplicateScans = (totalScans - validScans).clamp(0, totalScans);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF132A60).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_rounded, size: 16, color: Color(0xFF132A60)),
              ),
              const SizedBox(width: 8),
              const Text(
                "SCAN OVERVIEW TODAY",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Valid Admissions Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_user_rounded, size: 18, color: Color(0xFF059669)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        validScans.toString(),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Valid Entries",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Total Attempts Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        totalScans.toString(),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Total Scans",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Duplicate / Alerts Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        duplicateScans.toString(),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Duplicates",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB91C1C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          controller.setSearchQuery(val);
        },
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: "Search pass no, student, gate name...",
          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    controller.setSearchQuery('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        ),
      ),
    );
  }

  // --- Filter Chips Section ---
  Widget _buildFilterChipsSection() {
    return Obx(() {
      final selected = controller.selectedStatusFilter.value;
      return Row(
        children: [
          _buildFilterChip("All Scans", "all", selected == 'all', const Color(0xFF132A60)),
          const SizedBox(width: 6),
          _buildFilterChip("Valid Entry", "valid_entry", selected == 'valid_entry', const Color(0xFF10B981)),
          const SizedBox(width: 6),
          _buildFilterChip("Duplicates", "already_entered", selected == 'already_entered', const Color(0xFFEF4444)),
        ],
      );
    });
  }

  Widget _buildFilterChip(String label, String status, bool isSelected, Color activeColor) {
    return Expanded(
      child: InkWell(
        onTap: () => controller.setStatusFilter(status),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  // --- Scan Card Widget ---
  Widget _buildScanCard(EventScanItem item) {
    final bool isValid = item.scanStatus.toLowerCase() == 'valid_entry';
    final Color statusColor = isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final Color statusBgColor = isValid ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final IconData statusIcon = isValid ? Icons.check_circle_rounded : Icons.report_problem_rounded;
    final String statusLabel = isValid ? "VALID ENTRY" : "DUPLICATE ENTRY";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Pass Number & Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: statusBgColor.withValues(alpha: 0.55),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_rounded, size: 14, color: Color(0xFF132A60)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.passNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF132A60),
                              letterSpacing: 0.3,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Event Title Box
                if (item.eventTitle.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.event_note_rounded, size: 16, color: Color(0xFF7E22CE)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.eventTitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B21A8),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 3. Student Details Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          item.studentName.isNotEmpty ? item.studentName[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                item.studentName.isNotEmpty ? item.studentName : "Student",
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (item.admissionNo.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: Text(
                                    "Adm: ${item.admissionNo}",
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (item.classSection.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.school_outlined, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "Class: ${item.classSection}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 4. Scanning Metadata Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gate Name
                      if (item.gateName.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.sensor_door_rounded, size: 15, color: Color(0xFF0284C7)),
                            const SizedBox(width: 6),
                            const Text(
                              "Gate: ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.gateName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Scanned By
                      if (item.scannedBy.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.badge_rounded, size: 15, color: Color(0xFF6366F1)),
                            const SizedBox(width: 6),
                            const Text(
                              "Scanned By: ",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.scannedBy,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4338CA),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Time Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.access_time_filled_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          const Text(
                            "Scanned Time: ",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.scannedAtFull.isNotEmpty ? item.scannedAtFull : item.scannedAt,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 5. Duplicate Entry Alert Message Banner
                if (item.scanMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isValid ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isValid ? const Color(0xFFA7F3D0) : const Color(0xFFFCA5A5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isValid ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                          size: 18,
                          color: isValid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.scanMessage,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isValid ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Column(
            children: [
              Icon(Icons.qr_code_scanner_rounded, size: 56, color: Color(0xFFCBD5E1)),
              SizedBox(height: 12),
              Text(
                "No Event Scans Found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "No scan records match your filter criteria.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scanner Overlay CustomPainter matching screenshot styling
class _ScannerFramePainter extends CustomPainter {
  final double animationValue;
  final Size cutoutSize;
  final double cornerRadius;
  final Color accentColor;
  final Color scrimColor;

  _ScannerFramePainter({
    required this.animationValue,
    required this.cutoutSize,
    required this.cornerRadius,
    required this.accentColor,
    required this.scrimColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double left = (size.width - cutoutSize.width) / 2;
    final double top = (size.height - cutoutSize.height) / 2;
    final Rect cutoutRect = Rect.fromLTWH(left, top, cutoutSize.width, cutoutSize.height);
    final RRect rrect = RRect.fromRectAndRadius(cutoutRect, Radius.circular(cornerRadius));

    // Translucent Overlay
    final Path scrimPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    final Paint scrimPaint = Paint()
      ..color = scrimColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(scrimPath, scrimPaint);

    // Inner Cutout Rounded Border
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(rrect, borderPaint);

    // Animated Cyan Glow Laser Beam
    final double laserY = cutoutRect.top + 10 + (cutoutRect.height - 20) * animationValue;
    final Rect laserRect = Rect.fromLTWH(
      cutoutRect.left + 8,
      laserY - 1.5,
      cutoutRect.width - 16,
      3.0,
    );

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
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
