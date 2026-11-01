import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/services/app_update_service.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/banner_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/auth_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/dashboard_controller.dart';
import 'package:smart_aig_admins_app/view/screens/dashboard_screen.dart';
import 'package:smart_aig_admins_app/view/screens/setting_screen.dart';
import 'package:smart_aig_admins_app/view/screens/meeting_screen.dart';
import 'package:smart_aig_admins_app/view/screens/student_attendance_report_screen.dart';
import 'package:smart_aig_admins_app/view/screens/teacher_attendance_report_screen.dart';
import 'package:smart_aig_admins_app/view/screens/student_leave_screen.dart';
import 'package:smart_aig_admins_app/view/screens/teacher_leave_screen.dart';
import 'package:smart_aig_admins_app/view/screens/callback_screen.dart';
import 'package:smart_aig_admins_app/view/screens/assets_report.dart';
import 'package:smart_aig_admins_app/view/screens/transport_screen.dart';
import 'package:smart_aig_admins_app/view/screens/notification_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/notification_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'ADMINS DASHBOARD',
    'BANNER',
    'MEETINGS',
    'SETTINGS',
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }

    _screens = const [
      DashboardScreen(),
      BannerScreen(),
      MeetingScreen(),
      SettingScreen(),
    ];

    // Background check for app update on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService().checkForUpdate(context);
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  BoxDecoration _getScreenDecoration() {
    return AppColors.screenDecoration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getScreenDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawerEnableOpenDragGesture: false,

        // ================= APP BAR =================
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: _selectedIndex == 0
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Color(0xFF0F172A),
                      size: 26,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                )
              : null,
          toolbarHeight: AppColors.appBarToolbarHeight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: AppColors.appBarCenterTitle,
          title: Text(
            _titles[_selectedIndex],
            style: AppColors.appBarTitleStyle,
          ),
          actions: _selectedIndex == 0
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF0F172A),
                            size: 26,
                          ),
                          Obx(() {
                            final unreadCount =
                                NotificationController.to.unreadCount.value;

                            if (unreadCount > 0) {
                              return Positioned(
                                top: -3,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                      onPressed: () {
                        Get.to(() => const NotificationScreen());
                      },
                    ),
                  ),
                ]
              : null,
        ),

        // ================= NAVIGATION DRAWER =================
        drawer: _buildDrawer(context),

        // ================= BODY (Preserves tab state) =================
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),

        // ================= BOTTOM NAVIGATION =================
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  // ================= NAVIGATION DRAWER WIDGET =================

  Widget _buildDrawer(BuildContext context) {
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    // Calculate space to leave open at the bottom so the drawer extends exactly down to the top of the bottom navigation bar
    final double bottomInset = 38.0 + (Platform.isIOS ? 25.0 : 0.0) + MediaQuery.of(context).padding.bottom;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.only(bottom: bottomInset),
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Drawer Top Profile Card
                Obx(() {
                  final data = dashboardController.dashboardData.value;
                  final schoolLogo = data?.school.formattedLogo;
                  final teacherImage = data?.teacher.uploadedProfileImageUrl;
                  final displayImage = schoolLogo ?? teacherImage ?? data?.teacher.profileImageUrl;
                  final localPath = dashboardController.localImagePath.value;
                  final schoolName = data?.school.schoolName ?? "School Admin";
                  final schoolCode = data?.school.schoolCode ?? "";
                  final userName = data?.teacher.name ?? "Admin User";

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      top: 8,
                      left: 12,
                      right: 12,
                      bottom: 4,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: AppColors.cardBorderRadius,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.8,
                      ),
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
                        // 1. TOP ROW: Square Image on Left + Admin Name on Right
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Square School / Teacher Logo Box
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF64748B).withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: localPath.isNotEmpty && File(localPath).existsSync()
                                    ? Image.file(
                                        File(localPath),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildDrawerFallbackImage(displayImage),
                                      )
                                    : _buildDrawerFallbackImage(displayImage),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Admin / User Name & Verified Badge Inline
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: userName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const WidgetSpan(
                                            alignment: PlaceholderAlignment.middle,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 4),
                                              child: Image(
                                                image: AssetImage('assets/images/verified_badge.png'),
                                                width: 14,
                                                height: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // 2. DIVIDER LINE
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                          ),
                        ),

                        // 3. BOTTOM ROW: School Name & School ID Badge
                        Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: schoolName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF475569),
                                        height: 1.2,
                                      ),
                                    ),
                                    const WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Image(
                                          image: AssetImage('assets/images/verified_badge.png'),
                                          width: 13,
                                          height: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (schoolCode.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE9FE),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFDDD6FE),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "ID: $schoolCode",
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // Menu Items List where EVERY item is in its OWN CARD
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    children: [
                      _buildSingleItemCard(
                        icon: Icons.dashboard_rounded,
                        title: "Dashboard",
                        color: const Color(0xFF6366F1),
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(0);
                        },
                      ),
                      Obx(() {
                        final unread = NotificationController.to.unreadCount.value;
                        return _buildSingleItemCard(
                          icon: Icons.notifications_rounded,
                          title: "Notifications",
                          color: const Color(0xFF0EA5E9),
                          trailingWidget: unread > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    unread > 99 ? '99+' : '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const NotificationScreen());
                          },
                        );
                      }),
                      _buildSingleItemCard(
                        icon: Icons.view_carousel_rounded,
                        title: "Banners",
                        color: const Color(0xFFEC4899),
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(1);
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.groups_rounded,
                        title: "Meetings",
                        color: const Color(0xFF10B981),
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(2);
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.settings_rounded,
                        title: "Settings",
                        color: const Color(0xFF64748B),
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(3);
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.assignment_ind_rounded,
                        title: "Student Attendance",
                        color: const Color(0xFF6366F1),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const StudentAttendanceReportScreen());
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.supervisor_account_rounded,
                        title: "Teacher Attendance",
                        color: const Color(0xFF06B6D4),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const TeacherAttendanceReportScreen());
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.time_to_leave_rounded,
                        title: "Student Leave Requests",
                        color: const Color(0xFF10B981),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const StudentLeaveScreen());
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.free_cancellation_rounded,
                        title: "Teacher Leave Requests",
                        color: const Color(0xFF0D9488),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const TeacherLeaveScreen());
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.phone_callback_rounded,
                        title: "Callback Requests",
                        color: const Color(0xFFEF4444),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const CallbackScreen());
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.bar_chart_rounded,
                        title: "Assets Report",
                        color: const Color(0xFFF59E0B),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const AssetsReport());
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.directions_bus_rounded,
                        title: "Transport",
                        color: const Color(0xFFD97706),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => const TransportScreen());
                        },
                      ),
                      _buildSingleItemCard(
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        color: const Color(0xFFEF4444),
                        textColor: const Color(0xFFEF4444),
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context, authController);
                        },
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= SINGLE ITEM CARD WIDGET =================

  Widget _buildSingleItemCard({
    required IconData icon,
    required String title,
    required Color color,
    Color? textColor,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF90A4AE).withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (trailingWidget != null) ...[
                  trailingWidget,
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Are you sure you want to log out of the application?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFallbackImage(String? displayImage) {
    return displayImage != null && displayImage.isNotEmpty
        ? Image.network(
            displayImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.school_rounded,
              size: 26,
              color: Color(0xFF94A3B8),
            ),
          )
        : const Icon(
            Icons.school_rounded,
            size: 26,
            color: Color(0xFF94A3B8),
          );
  }

  Widget _buildBottomNavigationBar() {
    final Widget navBarWidget = Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: Platform.isIOS ? 25 : 0,
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF132A60),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF132A60).withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),
          child: _buildBottomNavItems(),
        ),
      ),
    );

    if (Platform.isAndroid) {
      return SafeArea(
        top: false,
        child: navBarWidget,
      );
    }

    return navBarWidget;
  }

  Widget _buildBottomNavItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          0,
          Icons.dashboard,
          'Dashboard',
        ),
        _buildNavItem(
          1,
          Icons.view_carousel_rounded,
          'Banner',
        ),
        _buildNavItem(
          2,
          Icons.groups_rounded,
          'Meetings',
        ),
        _buildNavItem(
          3,
          Icons.settings_rounded,
          'Setting',
        ),
      ],
    );
  }

  // ================= SINGLE NAV ITEM =================

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
  ) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
