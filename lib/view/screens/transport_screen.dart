import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_aig_admins_app/models/transport_alerts_model.dart';
import 'package:smart_aig_admins_app/models/transport_halts_model.dart';
import 'package:smart_aig_admins_app/models/transport_live_overview_model.dart';
import 'package:smart_aig_admins_app/models/transport_location_requests_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/transport_location_request_detail_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/transport_controller.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  late final TransportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<TransportController>()
        ? Get.find<TransportController>()
        : Get.put(TransportController());
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      CustomSnackBar.showError("Invalid Phone", "No valid phone number provided.", snackPosition: SnackPosition.TOP);
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error launching phone call: $e");
      }
      CustomSnackBar.showError("Call Failed", "Could not place call to $cleanPhone.", snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Container(
        decoration: AppColors.screenDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: AppColors.appBarToolbarHeight,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: AppColors.appBarCenterTitle,
            leading: const CustomBackButton(),
            title: const Text(
              "TRANSPORT MANAGEMENT",
              style: AppColors.appBarTitleStyle,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF132A60).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
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
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF132A60),
                        Color(0xFF1E40AF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF132A60).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                  tabs: const [
                    Tab(
                      height: 38,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sensors_rounded, size: 14),
                            SizedBox(width: 4),
                            Text("Live"),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      height: 38,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_location_alt_rounded, size: 14),
                            SizedBox(width: 4),
                            Text("Requests"),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      height: 38,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 14),
                            SizedBox(width: 4),
                            Text("Halts"),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      height: 38,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notification_important_rounded, size: 14),
                            SizedBox(width: 4),
                            Text("Alerts"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                _buildLiveOverviewTabContent(),
                _buildLocationRequestsTabContent(),
                _buildTransportHaltsTabContent(),
                _buildTransportAlertsTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== TAB 0: LIVE OVERVIEW ====================

  Widget _buildLiveOverviewTabContent() {
    return Obx(() {
      if (controller.isLiveOverviewLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.liveOverviewHasError.value) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchLiveOverview(),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 50, color: Color(0xFFEF4444)),
                    const SizedBox(height: 12),
                    Text(
                      controller.liveOverviewErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchLiveOverview(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final summary = controller.liveSummary;
      final fleet = controller.fleet;

      return RefreshIndicator(
        onRefresh: () => controller.fetchLiveOverview(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          children: [
            // Summary Stat Grid
            if (summary != null) _buildLiveOverviewSummaryGrid(summary),

            const SizedBox(height: 12),

            // Fleet List Header
            Row(
              children: [
                const Icon(Icons.directions_bus_rounded, size: 18, color: Color(0xFF132A60)),
                const SizedBox(width: 6),
                const Text(
                  "FLEET STATUS",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.5),
                ),
                const Spacer(),
                Text(
                  "${fleet.length} Vehicles",
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (fleet.isEmpty)
              _buildEmptyState("No live transport vehicles found.")
            else
              ...fleet.map((item) => _buildFleetCard(item)),
          ],
        ),
      );
    });
  }

  Widget _buildLiveOverviewSummaryGrid(TransportLiveSummary summary) {
    return Container(
      padding: const EdgeInsets.all(10),
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
        children: [
          // Row 1: Total Buses, Active Trips, Moving Buses
          Row(
            children: [
              _buildLiveStatPill(
                icon: Icons.directions_bus_rounded,
                count: summary.totalBuses.toString(),
                label: "Total Buses",
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
              ),
              const SizedBox(width: 6),
              _buildLiveStatPill(
                icon: Icons.alt_route_rounded,
                count: summary.activeTrips.toString(),
                label: "Active Trips",
                color: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
              ),
              const SizedBox(width: 6),
              _buildLiveStatPill(
                icon: Icons.navigation_rounded,
                count: summary.movingBuses.toString(),
                label: "Moving",
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFD1FAE5),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: Halted Buses, Signal Lost, Idle Buses
          Row(
            children: [
              _buildLiveStatPill(
                icon: Icons.pause_circle_rounded,
                count: summary.haltedBuses.toString(),
                label: "Halted",
                color: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEE2E2),
              ),
              const SizedBox(width: 6),
              _buildLiveStatPill(
                icon: Icons.signal_cellular_connected_no_internet_0_bar_rounded,
                count: summary.signalLost.toString(),
                label: "Signal Lost",
                color: const Color(0xFFF97316),
                bgColor: const Color(0xFFFFEDD5),
              ),
              const SizedBox(width: 6),
              _buildLiveStatPill(
                icon: Icons.access_time_rounded,
                count: summary.idleBuses.toString(),
                label: "Idle",
                color: const Color(0xFF64748B),
                bgColor: const Color(0xFFF1F5F9),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 3: Completed Trips, On Board, Alerts
          Row(
            children: [
              _buildLiveStatPill(
                icon: Icons.task_alt_rounded,
                count: summary.completedTripsToday.toString(),
                label: "Completed",
                color: const Color(0xFF0D9488),
                bgColor: const Color(0xFFCCFBF1),
              ),
              const SizedBox(width: 6),
              _buildLiveStatPill(
                icon: Icons.people_alt_rounded,
                count: summary.studentsOnBoard.toString(),
                label: "On Board",
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
              ),
              const SizedBox(width: 6),
              _buildLiveStatPill(
                icon: Icons.notification_important_rounded,
                count: summary.unresolvedAlerts.toString(),
                label: "Alerts",
                color: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEE2E2),
              ),
            ],
          ),

          // Updated At Footer
          if (summary.updatedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sync_rounded, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  "Last Updated: ${_formatUpdatedAt(summary.updatedAt!)}",
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatUpdatedAt(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} $hour:$min $amPm";
    } catch (_) {
      return raw;
    }
  }

  Widget _buildLiveStatPill({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetCard(TransportFleetItem item) {
    Color statusColor = const Color(0xFF10B981);
    Color statusBgColor = const Color(0xFFD1FAE5);
    IconData statusIcon = Icons.navigation_rounded;

    if (item.vehicleStatus?.toLowerCase() == 'signal_lost') {
      statusColor = const Color(0xFFF97316);
      statusBgColor = const Color(0xFFFFEDD5);
      statusIcon = Icons.signal_cellular_connected_no_internet_0_bar_rounded;
    } else if (item.vehicleStatus?.toLowerCase() == 'halted') {
      statusColor = const Color(0xFFEF4444);
      statusBgColor = const Color(0xFFFEE2E2);
      statusIcon = Icons.pause_circle_rounded;
    } else if (item.vehicleStatus?.toLowerCase() == 'idle') {
      statusColor = const Color(0xFF64748B);
      statusBgColor = const Color(0xFFF1F5F9);
      statusIcon = Icons.access_time_rounded;
    }

    final activeTrip = item.activeTrip;
    final driver = item.driver;
    final route = item.assignedRoute;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Bus Name & Plate + Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_bus_rounded, color: Color(0xFF1E293B), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          item.busNumber ?? "Bus ${item.busId}",
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.plateNumber != null && item.plateNumber!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            item.plateNumber!,
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        (item.vehicleStatusText ?? item.vehicleStatus ?? 'STATUS').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assigned Route & Driver Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (route?.name != null)
                            Row(
                              children: [
                                const Icon(Icons.alt_route_rounded, size: 14, color: Color(0xFF0284C7)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    route!.name!,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          if (driver?.name != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFF6366F1)),
                                const SizedBox(width: 4),
                                Text(
                                  "Driver: ${driver!.name!}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (driver?.phone != null && driver!.phone!.isNotEmpty)
                      IconButton(
                        onPressed: () => _makePhoneCall(driver.phone!),
                        constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                        ),
                        icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 16),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Active Trip Section
                if (activeTrip != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                activeTrip.tripTypeLabel?.toUpperCase() ?? "ACTIVE TRIP",
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                              ),
                            ),
                            const Spacer(),
                            if (activeTrip.elapsedFormatted != null)
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 13, color: Color(0xFF64748B)),
                                  const SizedBox(width: 3),
                                  Text(
                                    "Elapsed: ${activeTrip.elapsedFormatted}",
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        // Active Halt Box
                        if (activeTrip.activeHalt != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEF4444)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    activeTrip.activeHalt!.reason ?? "Vehicle Halted",
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF991B1B),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Manifest Progress Bar
                        if (activeTrip.passengerManifest != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "${activeTrip.passengerManifest!.boarded} / ${activeTrip.passengerManifest!.totalAllocated} Boarded",
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                              ),
                              const Spacer(),
                              Text(
                                "${activeTrip.passengerManifest!.progressPercent}%",
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (activeTrip.passengerManifest!.progressPercent / 100).clamp(0.0, 1.0),
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Telemetry Footer (Live Speed, Coordinates & Location Ping)
                if (activeTrip?.telemetry != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeTrip!.telemetry!.latitude != null && activeTrip.telemetry!.longitude != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.my_location_rounded, size: 13, color: Color(0xFF0284C7)),
                            const SizedBox(width: 4),
                            Text(
                              "GPS Coords: ${activeTrip.telemetry!.latitude}, ${activeTrip.telemetry!.longitude}",
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Last Ping: ${activeTrip.telemetry!.lastPingAgo ?? 'N/A'}",
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                            ),
                          ),
                          if (activeTrip.telemetry!.speed != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (activeTrip.telemetry!.speed ?? 0) > 0
                                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (activeTrip.telemetry!.speed ?? 0) > 0
                                      ? const Color(0xFF10B981).withValues(alpha: 0.5)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.speed_rounded,
                                    size: 13,
                                    color: (activeTrip.telemetry!.speed ?? 0) > 0
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Speed: ${activeTrip.telemetry!.speed} km/h",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: (activeTrip.telemetry!.speed ?? 0) > 0
                                          ? const Color(0xFF047857)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: LOCATION REQUESTS ====================

  Widget _buildLocationRequestsTabContent() {
    return Column(
      children: [
        const SizedBox(height: 8),

        // Overview Top Summary Cards
        Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.all(6),
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
                child: Row(
                  children: [
                    _buildTopSummaryCard(
                      icon: Icons.apps_rounded,
                      count: controller.totalCount.toString(),
                      label: "Total",
                      color: const Color(0xFF0284C7),
                      bgColor: const Color(0xFFE0F2FE),
                    ),
                    const SizedBox(width: 4),
                    _buildTopSummaryCard(
                      icon: Icons.pending_actions_rounded,
                      count: controller.pendingCount.toString(),
                      label: "Pending",
                      color: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFEF3C7),
                    ),
                    const SizedBox(width: 4),
                    _buildTopSummaryCard(
                      icon: Icons.check_circle_outline_rounded,
                      count: controller.approvedCount.toString(),
                      label: "Approved",
                      color: const Color(0xFF10B981),
                      bgColor: const Color(0xFFD1FAE5),
                    ),
                    const SizedBox(width: 4),
                    _buildTopSummaryCard(
                      icon: Icons.cancel_outlined,
                      count: controller.rejectedCount.toString(),
                      label: "Rejected",
                      color: const Color(0xFFEF4444),
                      bgColor: const Color(0xFFFEE2E2),
                    ),
                  ],
                ),
              ),
            )),

        const SizedBox(height: 10),

        // Filter Chips
        Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _buildFilterChip("All", "all", const Color(0xFF0284C7)),
                  const SizedBox(width: 4),
                  _buildFilterChip("Pending", "pending", const Color(0xFFD97706)),
                  const SizedBox(width: 4),
                  _buildFilterChip("Approved", "approved", const Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  _buildFilterChip("Rejected", "rejected", const Color(0xFFEF4444)),
                ],
              ),
            )),

        const SizedBox(height: 8),

        // Location Requests List
        Expanded(
          child: _buildLocationRequestsTab(),
        ),
      ],
    );
  }

  // --- Filter Chip Widget ---
  Widget _buildFilterChip(String title, String status, Color color) {
    final isSelected = controller.selectedStatus.value == status;
    return Expanded(
      child: InkWell(
        onTap: () => controller.fetchLocationRequests(status: status),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  // --- Top Summary Card ---
  Widget _buildTopSummaryCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              count,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Location Requests Content ---
  Widget _buildLocationRequestsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.hasError.value) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchLocationRequests(),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 50, color: Color(0xFFEF4444)),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchLocationRequests(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final requests = controller.requests;

      if (requests.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchLocationRequests(),
          child: ListView(
            children: [
              const SizedBox(height: 60),
              _buildEmptyState("No location requests found for '${controller.selectedStatus.value.toUpperCase()}'"),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchLocationRequests(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return _buildLocationRequestCard(req);
          },
        ),
      );
    });
  }

  Widget _buildLocationRequestCard(TransportLocationRequest req) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (req.status.toLowerCase()) {
      case 'approved':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        statusIcon = Icons.cancel_rounded;
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        statusIcon = Icons.pending_rounded;
        break;
    }

    final student = req.student;
    final propCoords = req.proposedCoordinates;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => TransportLocationRequestDetailScreen(
                  requestId: req.id,
                  initialRequest: req,
                ));
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: AppColors.cardBorderRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Request ID & Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: statusBgColor.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              "Request ${req.id}",
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              req.requestedByRole ?? "Parent",
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        req.statusLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
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
                    // Essential Info: Student Name & Class
                    if (student != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF6366F1)),
                          const SizedBox(width: 6),
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (student.className != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              "(Class ${student.className}-${student.sectionName ?? ''})",
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Essential Info: Proposed New Location
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Proposed New Location:",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  propCoords?.address ?? "Address not specified",
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Action Buttons Row: View Details + Approve/Reject if pending
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.to(() => TransportLocationRequestDetailScreen(
                                    requestId: req.id,
                                    initialRequest: req,
                                  ));
                            },
                            icon: const Icon(Icons.visibility_rounded, size: 15, color: Color(0xFF0038A8)),
                            label: const Text(
                              "View Details",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0038A8),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: Color(0xFF0038A8), width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        if (req.status.toLowerCase().contains('pending')) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: controller.isActionLoading.value
                                  ? null
                                  : () => _showApproveDialog(context, req),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Approve",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: controller.isActionLoading.value
                                  ? null
                                  : () => _showRejectDialog(context, req),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Reject",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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

  // ==================== TAB 2: TRANSPORT HALTS ====================

  Widget _buildTransportHaltsTabContent() {
    return Column(
      children: [
        const SizedBox(height: 8),

        // Halts Filter Chips
        Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _buildHaltFilterChip("All Halts", "all", const Color(0xFF0284C7)),
                  const SizedBox(width: 6),
                  _buildHaltFilterChip("Active / Ongoing", "active", const Color(0xFFD97706)),
                  const SizedBox(width: 6),
                  _buildHaltFilterChip("Resolved", "resolved", const Color(0xFF10B981)),
                ],
              ),
            )),

        const SizedBox(height: 8),

        // Halts List View
        Expanded(
          child: Obx(() {
            if (controller.isHaltsLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.haltsHasError.value) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchTransportHalts(),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 50, color: Color(0xFFEF4444)),
                          const SizedBox(height: 12),
                          Text(
                            controller.haltsErrorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchTransportHalts(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final halts = controller.halts;

            if (halts.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchTransportHalts(),
                child: ListView(
                  children: [
                    const SizedBox(height: 60),
                    _buildEmptyState("No transport halts found for '${controller.selectedHaltStatus.value.toUpperCase()}'"),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchTransportHalts(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                itemCount: halts.length,
                itemBuilder: (context, index) {
                  final halt = halts[index];
                  return _buildHaltCard(halt);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHaltFilterChip(String title, String status, Color color) {
    final isSelected = controller.selectedHaltStatus.value == status;
    return Expanded(
      child: InkWell(
        onTap: () => controller.fetchTransportHalts(status: status),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHaltCard(TransportHalt halt) {
    final bus = halt.bus;
    final trip = halt.trip;
    final location = halt.location;
    final bool isOngoing = halt.isOngoing;

    final Color statusColor = isOngoing ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final Color statusBgColor = isOngoing ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Bus & Plate with Ongoing / Resolved Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isOngoing ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                  color: statusColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          bus?.busNumber ?? "Halt ${halt.id}",
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (bus?.plateNumber != null && bus!.plateNumber!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            bus.plateNumber!,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOngoing ? "ONGOING" : "RESOLVED",
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
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
                // Reason / Emergency Box
                if (halt.reason != null && halt.reason!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isOngoing ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOngoing ? const Color(0xFFFCA5A5) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.report_problem_rounded,
                          size: 18,
                          color: isOngoing ? const Color(0xFFEF4444) : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            halt.reason!,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isOngoing ? const Color(0xFF991B1B) : const Color(0xFF92400E),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Trip & Route Info
                if (trip != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alt_route_rounded, size: 16, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.routeName ?? 'Route Info',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (trip.tripType != null)
                                Text(
                                  "Trip Type: ${trip.tripType!.toUpperCase()}",
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Location Box (Address + GPS Coordinates)
                if (location != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEF4444)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Halt Location Address:",
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    location.address ?? "Address not specified",
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (location.latitude != null && location.longitude != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.my_location_rounded, size: 12, color: Color(0xFF0284C7)),
                                const SizedBox(width: 4),
                                Text(
                                  "GPS Coords: ${location.latitude}, ${location.longitude}",
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Time & Duration Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        "Started: ${halt.startedAtTime ?? halt.startedAt ?? 'N/A'}",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                      const Spacer(),
                      if (halt.durationFormatted != null)
                        Text(
                          halt.durationFormatted!,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                        ),
                    ],
                  ),
                ),

                // Driver Info & Call / Alert Row
                if (trip?.driverName != null || halt.isAlertSent) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (trip?.driverName != null) ...[
                        const Icon(Icons.person_pin_rounded, size: 16, color: Color(0xFF6366F1)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Driver: ${trip!.driverName}",
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                              if (trip.driverPhone != null)
                                Text(
                                  trip.driverPhone!,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (halt.isAlertSent) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.notifications_active_rounded, size: 12, color: Color(0xFFD97706)),
                              SizedBox(width: 4),
                              Text(
                                "Alert Sent",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (trip?.driverPhone != null && trip!.driverPhone!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _makePhoneCall(trip.driverPhone!),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                          ),
                          icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 18),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: TRANSPORT ALERTS ====================

  Widget _buildTransportAlertsTabContent() {
    return Column(
      children: [
        const SizedBox(height: 8),

        // Alerts Filter Chips (Status)
        Obx(() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _buildAlertFilterChip("Unresolved", "unresolved", const Color(0xFFEF4444)),
                  const SizedBox(width: 6),
                  _buildAlertFilterChip("Resolved", "resolved", const Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  _buildAlertFilterChip("All Alerts", "all", const Color(0xFF0284C7)),
                ],
              ),
            )),

        const SizedBox(height: 8),

        // Alerts List View
        Expanded(
          child: Obx(() {
            if (controller.isAlertsLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.alertsHasError.value) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchTransportAlerts(),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 50, color: Color(0xFFEF4444)),
                          const SizedBox(height: 12),
                          Text(
                            controller.alertsErrorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchTransportAlerts(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final alerts = controller.alerts;

            if (alerts.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchTransportAlerts(),
                child: ListView(
                  children: [
                    const SizedBox(height: 60),
                    _buildEmptyState("No transport alerts found for '${controller.selectedAlertStatus.value.toUpperCase()}'"),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchTransportAlerts(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return _buildAlertCard(alert);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAlertFilterChip(String title, String status, Color color) {
    final isSelected = controller.selectedAlertStatus.value == status;
    return Expanded(
      child: InkWell(
        onTap: () => controller.fetchTransportAlerts(status: status),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(TransportAlert alert) {
    final bool isCritical = alert.severity?.toLowerCase() == 'critical';
    final bool isResolved = alert.isResolved;

    Color severityColor = const Color(0xFFEF4444); // Red default
    Color severityBgColor = const Color(0xFFFEE2E2);

    if (alert.severity?.toLowerCase() == 'high') {
      severityColor = const Color(0xFFF97316);
      severityBgColor = const Color(0xFFFFEDD5);
    } else if (alert.severity?.toLowerCase() == 'medium') {
      severityColor = const Color(0xFFD97706);
      severityBgColor = const Color(0xFFFEF3C7);
    } else if (alert.severity?.toLowerCase() == 'low') {
      severityColor = const Color(0xFF0284C7);
      severityBgColor = const Color(0xFFE0F2FE);
    }

    final Color statusColor = isResolved ? const Color(0xFF10B981) : severityColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Severity Icon, Title, Resolution Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isResolved
                  ? const Color(0xFFD1FAE5).withValues(alpha: 0.5)
                  : severityBgColor.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCritical
                      ? Icons.notification_important_rounded
                      : (isResolved ? Icons.check_circle_rounded : Icons.warning_amber_rounded),
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.title ?? alert.alertTypeLabel ?? "Alert ${alert.id}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isResolved ? "RESOLVED" : (alert.severity?.toUpperCase() ?? "UNRESOLVED"),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
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
                // Alert Message Box
                if (alert.message != null && alert.message!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isResolved ? const Color(0xFFF8FAFC) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isResolved ? const Color(0xFFE2E8F0) : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Text(
                      alert.message!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isResolved ? const Color(0xFF334155) : const Color(0xFF991B1B),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Route & Bus Info Row
                if (alert.bus != null || alert.route != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bus_rounded, size: 18, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${alert.bus?.busNumber ?? 'Bus'} ${alert.bus?.plateNumber != null ? '(${alert.bus!.plateNumber})' : ''}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                              if (alert.route?.name != null)
                                Text(
                                  "Route: ${alert.route!.name}",
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF0284C7)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Location Box (Location Name & GPS Coordinates)
                if (alert.location != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEF4444)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Reported Location:",
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    alert.location!.locationName ?? "Location not specified",
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (alert.location!.latitude != null && alert.location!.longitude != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFBAE6FD)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.my_location_rounded, size: 12, color: Color(0xFF0284C7)),
                                const SizedBox(width: 4),
                                Text(
                                  "GPS Coords: ${alert.location!.latitude}, ${alert.location!.longitude}",
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Reported By / Driver & Time Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      alert.createdAtTime ?? alert.createdAtAgo ?? '',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                    ),
                    const Spacer(),
                    if (alert.driver?.phone != null && alert.driver!.phone!.isNotEmpty)
                      IconButton(
                        onPressed: () => _makePhoneCall(alert.driver!.phone!),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                        ),
                        icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 18),
                      ),
                  ],
                ),

                // Resolution Details Box (if resolved)
                if (isResolved ||
                    alert.resolvedByName != null ||
                    (alert.resolutionNotes != null && alert.resolutionNotes!.isNotEmpty)) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF10B981)),
                            SizedBox(width: 6),
                            Text(
                              "Resolution Details",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        if (alert.resolutionNotes != null && alert.resolutionNotes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            alert.resolutionNotes!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF14532D),
                            ),
                          ),
                        ],
                        if (alert.resolvedByName != null || alert.resolvedAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Resolved by: ${alert.resolvedByName ?? 'Admin'}"
                            "${alert.resolvedAt != null ? ' • ${_formatActionAt(alert.resolvedAt!)}' : ''}",
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Resolve Action Button (if unresolved)
                if (!isResolved) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: controller.isAlertActionLoading.value
                          ? null
                          : () => _showResolveAlertDialog(context, alert),
                      icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        "Resolve Alert",
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
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

  // --- Helpers ---

  void _showResolveAlertDialog(BuildContext context, TransportAlert alert) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 8),
              Text(
                "Resolve Alert",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to mark this emergency alert as resolved?",
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Optional resolution notes...",
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await controller.resolveAlert(
                  alert.id,
                  resolutionNotes: notesController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Resolve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showApproveDialog(BuildContext context, TransportLocationRequest req) {
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 8),
              Text(
                "Approve Request",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to approve the transport location change for ${req.student?.name ?? 'this student'}?",
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
              ),
              if (req.proposedCoordinates?.address != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "New Address: ${req.proposedCoordinates!.address}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: remarksController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Optional remarks...",
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await controller.approveRequest(
                  req.id,
                  remarks: remarksController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, TransportLocationRequest req) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 24),
              SizedBox(width: 8),
              Text(
                "Reject Request",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please enter a reason for rejecting the request for ${req.student?.name ?? 'this student'}:",
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Rejection reason is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Reason for rejection...",
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  await controller.rejectRequest(
                    req.id,
                    reasonController.text.trim(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _formatActionAt(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, size: 50, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
