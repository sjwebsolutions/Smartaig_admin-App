import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_aig_admins_app/models/dashboard_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/utils/custom_snackbar.dart';
import 'package:smart_aig_admins_app/view_models/getX/auth_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/dashboard_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/policy_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/support_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final AuthController authController = Get.find<AuthController>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final PolicyController policyController = Get.put(PolicyController());
  final SupportController supportController = Get.put(SupportController());
  String _appVersion = "2.0.1+21";

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  void _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint("Error loading package info: $e");
    }
  }

  String? _formatFullAddress(UserModel? user) {
    if (user == null) return null;
    final parts = [
      if (user.address != null && user.address!.trim().isNotEmpty)
        user.address!.trim(),
      if (user.district != null && user.district!.trim().isNotEmpty)
        user.district!.trim(),
      if (user.state != null && user.state!.trim().isNotEmpty)
        user.state!.trim(),
      if (user.pincode != null && user.pincode!.trim().isNotEmpty)
        user.pincode!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final bool isPushed = ModalRoute.of(context)?.canPop ?? false;

    return Container(
      decoration: AppColors.screenDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: isPushed
              ? AppBar(
                  toolbarHeight: AppColors.appBarToolbarHeight,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: AppColors.appBarCenterTitle,
                  leading: const CustomBackButton(),
                  title: const Text(
                    "SETTINGS",
                    style: AppColors.appBarTitleStyle,
                  ),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: () async {
              await dashboardController.fetchDashboardData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Obx(() {
                final data = dashboardController.dashboardData.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // Top Profile Container Card with All Details
                    _buildTopProfileCard(data),

                    const SizedBox(height: 14),

                    // Contact Support Card
                    _buildActionCard(
                      icon: Icons.headset_mic_rounded,
                      title: "Contact Support",
                      subtitle: "Get help and support",
                      iconColor: const Color(0xFF0284C7),
                      iconBgColor: const Color(0xFFE0F2FE),
                      onTap: _handleSupportTap,
                    ),

                    // Privacy Policy Card
                    _buildActionCard(
                      icon: Icons.shield_rounded,
                      title: "Privacy Policy",
                      subtitle: "Read our privacy policy",
                      iconColor: const Color(0xFF16A34A),
                      iconBgColor: const Color(0xFFDCFCE7),
                      onTap: () => _openPolicyDialog(
                        "Privacy Policy",
                        Icons.privacy_tip_outlined,
                        true,
                      ),
                    ),

                    // Terms Of Use Card
                    _buildActionCard(
                      icon: Icons.description_rounded,
                      title: "Terms Of Use",
                      subtitle: "Read our terms and conditions",
                      iconColor: const Color(0xFFCA8A04),
                      iconBgColor: const Color(0xFFFEF9C3),
                      onTap: () => _openPolicyDialog(
                        "Terms Of Use",
                        Icons.description_outlined,
                        false,
                      ),
                    ),

                    // App Version Card
                    _buildActionCard(
                      icon: Icons.info_rounded,
                      title: "App Version",
                      subtitle: "Current version $_appVersion",
                      iconColor: const Color(0xFF6366F1),
                      iconBgColor: const Color(0xFFEDE9FE),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFC7D2FE),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _appVersion,
                          style: const TextStyle(
                            color: Color(0xFF4338CA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Logout Card
                    Obx(
                      () => _buildActionCard(
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        subtitle: "Log out of your account",
                        iconColor: const Color(0xFFEF4444),
                        iconBgColor: const Color(0xFFFEE2E2),
                        isDestructive: true,
                        trailing: authController.isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                        onTap: authController.isLoading.value
                            ? null
                            : () => _showLogoutDialog(context),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopProfileCard(DashboardData? data) {
    final teacher = data?.teacher;
    final school = data?.school;
    final String? teacherUrl = teacher?.uploadedProfileImageUrl;
    final String? logoUrl = school?.formattedLogo;
    final String? displayUrl = (logoUrl != null && logoUrl.isNotEmpty)
        ? logoUrl
        : teacherUrl ??
            (teacher?.profileImageUrl.isNotEmpty == true
                ? teacher?.profileImageUrl
                : null);

    final String userName = teacher?.name ?? "N/A";
    final String schoolName = school?.schoolName ?? "";
    final String statusText = teacher?.status.isNotEmpty == true
        ? teacher!.status.toUpperCase()
        : "ACTIVE";
    final String fullAddress =
        _formatFullAddress(teacher) ?? (schoolName.isNotEmpty ? schoolName : "");

    // Collect all available mini grid items dynamically
    final List<Widget> miniGridItems = [];

    // 1. School ID
    if (school?.schoolCode.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.school_rounded,
        label: "School ID",
        value: school!.schoolCode,
        iconColor: const Color(0xFF6366F1),
      ));
    }

    // 2. Teacher Unique ID
    if (teacher?.teacherUniqueId.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.badge_rounded,
        label: "Teacher ID",
        value: teacher!.teacherUniqueId,
        iconColor: const Color(0xFF0EA5E9),
      ));
    }

    // 3. Phone Number
    if (teacher?.phone.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.phone_rounded,
        label: "Phone Number",
        value: teacher!.phone,
        iconColor: const Color(0xFF0284C7),
        onTap: () => _launchURL("tel:${teacher.phone}"),
      ));
    }

    // 4. WhatsApp Number
    if (teacher?.whatsappNumber.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.chat_bubble_rounded,
        customIcon: const FaIcon(
          FontAwesomeIcons.whatsapp,
          size: 18,
          color: Color(0xFF25D366),
        ),
        label: "WhatsApp",
        value: teacher!.whatsappNumber,
        iconColor: const Color(0xFF25D366),
        onTap: () {
          final cleanPhone = teacher.whatsappNumber.replaceAll(RegExp(r'[^\d]'), '');
          _launchURL("https://wa.me/$cleanPhone");
        },
      ));
    }

    // 5. Active Session
    if (data?.activeSession.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.calendar_today_rounded,
        label: "Active Session",
        value: data!.activeSession,
        iconColor: const Color(0xFF10B981),
      ));
    }

    // 6. Gender
    if (teacher?.gender.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.person_outline_rounded,
        label: "Gender",
        value: teacher!.gender,
        iconColor: const Color(0xFF8B5CF6),
      ));
    }

    // 7. Designation
    if (teacher?.staffType.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.assignment_ind_rounded,
        label: "Designation",
        value: teacher!.staffType,
        iconColor: const Color(0xFFF59E0B),
      ));
    }

    // 8. Date of Birth
    if (teacher?.dob != null && teacher!.dob!.trim().isNotEmpty) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.cake_rounded,
        label: "Date of Birth",
        value: teacher.dob!,
        iconColor: const Color(0xFFEC4899),
      ));
    }

    // 9. AIG Memo No
    if (school?.aigMembershipId.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.card_membership_rounded,
        label: "AIG Memo No",
        value: school!.aigMembershipId,
        iconColor: const Color(0xFF6366F1),
      ));
    }

    // 10. Validity Till
    if (school?.validityTill.isNotEmpty == true) {
      miniGridItems.add(_buildMiniGridCard(
        icon: Icons.event_available_rounded,
        label: "Validity Till",
        value: school!.validityTill,
        iconColor: const Color(0xFF10B981),
      ));
    }

    // Full-Width Cards (Experience, Email & Address)
    final List<Widget> fullWidthItems = [];

    // Experience
    if (teacher?.experience != null &&
        teacher!.experience.toString().trim().isNotEmpty) {
      final expStr = teacher.experience.toString().trim();
      fullWidthItems.add(_buildMiniFullWidthCard(
        icon: Icons.work_history_rounded,
        label: "Experience",
        value: expStr.toLowerCase().contains("year") ? expStr : "$expStr Yrs",
        iconColor: const Color(0xFF0D9488),
      ));
    }

    // Email
    if (teacher?.email != null && teacher!.email!.trim().isNotEmpty) {
      fullWidthItems.add(_buildMiniFullWidthCard(
        icon: Icons.email_rounded,
        label: "Email Address",
        value: teacher.email!,
        iconColor: const Color(0xFFF59E0B),
      ));
    }

    // Address
    if (fullAddress.isNotEmpty) {
      fullWidthItems.add(_buildMiniFullWidthCard(
        icon: Icons.location_on_rounded,
        label: "School / Address",
        value: fullAddress,
        iconColor: const Color(0xFFEF4444),
      ));
    }

    // Build 2-column paired rows
    final List<Widget> gridRows = [];
    for (int i = 0; i < miniGridItems.length; i += 2) {
      final item1 = miniGridItems[i];
      final item2 =
          (i + 1 < miniGridItems.length) ? miniGridItems[i + 1] : null;

      gridRows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(child: item1),
              const SizedBox(width: 8),
              if (item2 != null)
                Expanded(child: item2)
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
          // Top Profile Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Square/Rounded Avatar Box
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Obx(() {
                    final String localPath = dashboardController.localImagePath.value;
                    if (localPath.isNotEmpty && File(localPath).existsSync()) {
                      return Image.file(
                        File(localPath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildNetworkOrFallbackAvatar(displayUrl, teacherUrl),
                      );
                    }
                    return _buildNetworkOrFallbackAvatar(displayUrl, teacherUrl);
                  }),
                ),
              ),
              const SizedBox(width: 12),

              // User Name, School Name, Status Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: userName,
                            style: const TextStyle(
                              fontSize: 16,
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
                                width: 15,
                                height: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (schoolName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: schoolName,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
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
                    ],
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE0E7FF),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          ),

          // 2-Column Grid Mini Cards
          ...gridRows,

          // Full-width Cards (Email, Address, etc.)
          ...fullWidthItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: item,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGridCard({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = const Color(0xFF0284C7),
    Widget? customIcon,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                customIcon ??
                    Icon(
                      icon,
                      size: 18,
                      color: iconColor,
                    ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value.isNotEmpty ? value : "N/A",
                        maxLines: 2,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          height: 1.15,
                        ),
                      ),
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

  Widget _buildMiniFullWidthCard({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = const Color(0xFF0284C7),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : "N/A",
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: Colors.white,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppColors.cardBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDestructive ? Colors.red : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDestructive ? Colors.red.shade300 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDestructive ? Colors.red : const Color(0xFF94A3B8),
                      size: 20,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkOrFallbackAvatar(String? displayUrl, String? teacherUrl) {
    return displayUrl != null && displayUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: displayUrl,
            fit: BoxFit.cover,
            memCacheWidth: 150,
            memCacheHeight: 150,
            placeholder: (context, url) => _buildDefaultAvatar(
                isPerson: displayUrl == teacherUrl),
            errorWidget: (context, url, error) =>
                _buildDefaultAvatar(
                    isPerson: displayUrl == teacherUrl),
          )
        : _buildDefaultAvatar(isPerson: true);
  }

  Widget _buildDefaultAvatar({bool isPerson = false}) {
    return Container(
      color: isPerson ? const Color(0xFFEDE9FE) : const Color(0xFFE2E8F0),
      child: Center(
        child: Icon(
          isPerson ? Icons.person_rounded : Icons.school_rounded,
          size: isPerson ? 30 : 36,
          color: isPerson ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  void _handleSupportTap() {
    if (supportController.isLoading.value) {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF0038A8)),
        ),
        barrierDismissible: false,
      );
      supportController.fetchSupportSettings().then((_) {
        Get.back();
        if (mounted) _showSupportDialog(context);
      });
    } else {
      if (supportController.supportData.value == null) {
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0038A8),
            ),
          ),
          barrierDismissible: false,
        );
        supportController.fetchSupportSettings().then((_) {
          Get.back();
          if (mounted) _showSupportDialog(context);
        });
      } else {
        _showSupportDialog(context);
      }
    }
  }

  void _openPolicyDialog(String title, IconData icon, bool isPrivacyPolicy) {
    if (policyController.isLoading.value) {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF0038A8)),
        ),
        barrierDismissible: false,
      );
      policyController.getPolicy().then((_) {
        Get.back();
        _showCenterPolicyDialog(
          title: title,
          htmlContent: isPrivacyPolicy
              ? policyController.privacyPolicy
              : policyController.termsOfUse,
          icon: icon,
        );
      });
    } else {
      _showCenterPolicyDialog(
        title: title,
        htmlContent: isPrivacyPolicy
            ? policyController.privacyPolicy
            : policyController.termsOfUse,
        icon: icon,
      );
    }
  }

  void _showCenterPolicyDialog({
    required String title,
    required String htmlContent,
    required IconData icon,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 12,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.78,
            maxWidth: 440,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0038A8).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF0038A8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Scrollable Policy HTML/Text Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: htmlContent.trim().isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              "No content available.",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : HtmlWidget(
                          htmlContent,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF334155),
                            fontFamily: 'Inter',
                          ),
                          customStylesBuilder: (element) {
                            if (element.localName == 'h1') {
                              return {
                                'font-size': '18px',
                                'font-weight': 'bold',
                                'color': '#1E293B',
                                'margin-bottom': '10px',
                                'margin-top': '6px',
                              };
                            }
                            if (element.localName == 'h2') {
                              return {
                                'font-size': '16px',
                                'font-weight': 'bold',
                                'color': '#334155',
                                'margin-bottom': '8px',
                              };
                            }
                            if (element.localName == 'p') {
                              return {'margin-bottom': '12px'};
                            }
                            if (element.localName == 'a') {
                              return {
                                'color': '#0038A8',
                                'text-decoration': 'none',
                                'font-weight': '600',
                              };
                            }
                            return null;
                          },
                        ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Bottom Close Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: AppColors.buttonTextColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: AppColors.buttonShape,
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    final support = supportController.supportData.value;
    if (support == null) {
      CustomSnackBar.showError(
        "Error",
        "Support details not loaded yet. Please try again.",
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_outlined, color: Color(0xFF0038A8)),
            SizedBox(width: 8),
            Text(
              "Contact Support",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (support.name.isNotEmpty) ...[
              Text(
                support.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (support.mobile.isNotEmpty)
              _buildSupportDialogItem(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                title: "Call Us",
                subtitle: support.mobile,
                onTap: () => _launchURL("tel:${support.mobile}"),
              ),
            if (support.whatsapp.isNotEmpty)
              _buildSupportDialogItem(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Color(0xFF25D366),
                    size: 20,
                  ),
                ),
                title: "WhatsApp",
                subtitle: support.whatsapp,
                onTap: () {
                  final whatsappUrl =
                      "https://wa.me/${support.whatsapp.replaceAll(RegExp(r'[^\d]'), '')}";
                  _launchURL(whatsappUrl);
                },
              ),
            if (support.email.isNotEmpty)
              _buildSupportDialogItem(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.email_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                title: "Email Support",
                subtitle: support.email,
                onTap: () => _launchURL("mailto:${support.email}"),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(
                color: Color(0xFF0038A8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportDialogItem({
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        CustomSnackBar.showError("Error", "Could not open $urlString");
      }
    } catch (e) {
      CustomSnackBar.showError("Error", "Could not open link");
    }
  }
}
