import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view/screens/meeting_screen.dart';
import 'package:smart_aig_admins_app/view/screens/deadlines_screen.dart';
import 'package:smart_aig_admins_app/view/screens/announcement_screen.dart';
import 'package:smart_aig_admins_app/view/screens/banner_screen.dart';
import 'package:smart_aig_admins_app/view/screens/billing_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/meeting_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/deadlines_controller.dart';

import '../../view_models/getX/dashboard_controller.dart';
import 'assets_report.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    final MeetingController meetingController = Get.put(MeetingController());
    final DeadlinesController deadlinesController = Get.put(DeadlinesController());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3E9FF),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.dashboardData.value;
        if (data == null) {
          return const Center(child: Text("No data available"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchDashboardData();
            await meetingController.fetchMeetings();
            await deadlinesController.fetchDeadlines();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // School Logo & Name Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF0038A8).withOpacity(0.1), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: data.school.logo != null && data.school.logo!.isNotEmpty
                                    ? Image.network(
                                        data.school.logo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(
                                            Icons.school_rounded,
                                            size: 40,
                                            color: Color(0xFF0038A8),
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.school_rounded,
                                          size: 40,
                                          color: Color(0xFF0038A8),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data.school.schoolName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${data.school.schoolCode}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Statistics Section
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFF6366F1),
                              title: "Total Students",
                              value: data.totalActiveStudents.toString(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.school_rounded,
                              color: const Color(0xFF10B981),
                              title: "Total Teachers",
                              value: data.totalActiveTeachers.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Administration Card (The "Modules" Container)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row(
                            //   children: [
                            //     // Container(
                            //     //   width: 3,
                            //     //   height: 14,
                            //     //   decoration: BoxDecoration(
                            //     //     color: const Color(0xFF0038A8),
                            //     //     borderRadius: BorderRadius.circular(10),
                            //     //   ),
                            //     //),
                            //     const SizedBox(width: 8),
                            //     // const Text(
                            //     //   "Communication Modules",
                            //     //   style: TextStyle(
                            //     //     fontSize: 14,
                            //     //     fontWeight: FontWeight.bold,
                            //     //     color: Color(0xFF1E293B),
                            //     //   ),
                            //     // ),
                            //   ],
                            // ),
                            // const SizedBox(height: 10),
                            // Admin Menu Grid
                            GridView.count(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 15,
                              childAspectRatio: 1.2,
                              children: [
                                _buildGridMenuItem(
                                  icon: Icons.campaign_rounded,
                                  color: const Color(0xFF3B82F6),
                                  title: "Announcement",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AnnouncementScreen()),
                                    );
                                  },
                                ),
                                Obx(() {
                                  final upcomingCount = meetingController.todayOngoingMeetings.length;
                                  
                                  return _buildGridMenuItem(
                                    icon: Icons.groups_rounded,
                                    color: const Color(0xFF10B981),
                                    title: "Meetings",
                                    badgeCount: upcomingCount > 0 ? upcomingCount : null,
                                    badgeColor: const Color(0xFF47CB51),
                                    badgeBorderColor: const Color(0xFFA5F7BA),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MeetingScreen()),
                                      );
                                    },
                                  );
                                }),
                                Obx(() {
                                  final upcomingDeadlinesCount = deadlinesController.deadlinesList.where((d) => (d.daysRemaining ?? 0) >= 0).length;
                                  return _buildGridMenuItem(
                                    icon: Icons.event_available_rounded,
                                    color: const Color(0xFFF59E0B),
                                    title: "Deadlines",
                                    badgeCount: upcomingDeadlinesCount > 0 ? upcomingDeadlinesCount : null,
                                    badgeColor: Colors.red,
                                    isBlinking: false,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const DeadlinesScreen()),
                                      );
                                    },
                                  );
                                }),
                                _buildGridMenuItem(
                                  icon: Icons.view_carousel_rounded,
                                  color: const Color(0xFF8B5CF6),
                                  title: "Banners",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BannerScreen()),
                                    );
                                  },
                                ),
                                _buildGridMenuItem(
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: const Color(0xFFEC4899),
                                  title: "Billing",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BillingScreen()),
                                    );
                                  },
                                ),
                                _buildGridMenuItem(
                                  icon: Icons.assessment_rounded,
                                  color: const Color(0xFF0EA5E9), // Modern Sky Blue
                                  title: "Assets Report",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AssetsReport()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildGridMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
    Color? badgeColor,
    Color? badgeBorderColor,
    Color? iconBgColor,
    bool isBlinking = true,
  }) {
    Widget badge = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: badgeColor ?? Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: badgeBorderColor ?? Colors.white, width: 2),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Center(
        child: Text(
          badgeCount?.toString() ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: color.withAlpha(20), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconBgColor ?? color.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: isBlinking ? BlinkingBadge(child: badge) : badge,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class BlinkingBadge extends StatefulWidget {
  final Widget child;
  const BlinkingBadge({super.key, required this.child});

  @override
  State<BlinkingBadge> createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<BlinkingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.9, end: 1.1).animate(_controller),
      child: FadeTransition(
        opacity: Tween(begin: 0.6, end: 1.0).animate(_controller),
        child: widget.child,
      ),
    );
  }
}
