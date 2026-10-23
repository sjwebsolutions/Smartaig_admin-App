import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
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
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildProfileCard(),
                const SizedBox(height: 10),
                _buildPhoneCard(),
                const SizedBox(height: 10),
                _buildAppVersionCard(),
                const SizedBox(height: 10),
                _buildPrivacyPolicyCard(),
                const SizedBox(height: 10),
                _buildTermsCard(),
                const SizedBox(height: 10),
                _buildSupportCard(),
                const SizedBox(height: 10),
                _buildLogoutCard(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color iconColor = const Color(0xFF0038A8),
    Color titleColor = const Color(0xFF1E293B),
    bool isDestructive = false,
  }) {
    final effectiveIconColor = isDestructive ? Colors.red : iconColor;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppColors.cardBorderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: subtitle != null ? 12 : 14,
                          fontWeight: subtitle != null ? FontWeight.w500 : FontWeight.w600,
                          color: isDestructive
                              ? Colors.red
                              : (subtitle != null ? const Color(0xFF64748B) : titleColor),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Obx(() {
      final user = dashboardController.dashboardData.value?.teacher;
      return _buildSettingCard(
        icon: Icons.person_outline_rounded,
        title: "Logged By",
        subtitle: user?.name ?? "N/A",
      );
    });
  }

  Widget _buildPhoneCard() {
    return Obx(() {
      final user = dashboardController.dashboardData.value?.teacher;
      return _buildSettingCard(
        icon: Icons.phone_android_rounded,
        title: "Registered Mobile",
        subtitle: user?.phone ?? "N/A",
      );
    });
  }

  Widget _buildAppVersionCard() {
    return _buildSettingCard(
      icon: Icons.info_outline_rounded,
      title: "App Version",
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _appVersion,
          style: const TextStyle(
            color: Color(0xFF0038A8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyCard() {
    return _buildSettingCard(
      icon: Icons.privacy_tip_outlined,
      title: "Privacy Policy",
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () => _openPolicyDialog("Privacy Policy", Icons.privacy_tip_outlined, true),
    );
  }

  Widget _buildTermsCard() {
    return _buildSettingCard(
      icon: Icons.description_outlined,
      title: "Terms of Use",
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () => _openPolicyDialog("Terms of Use", Icons.description_outlined, false),
    );
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

  Widget _buildSupportCard() {
    return _buildSettingCard(
      icon: Icons.headset_mic_outlined,
      title: "Contact Support",
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () {
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
      },
    );
  }

  Widget _buildLogoutCard() {
    return Obx(
      () => _buildSettingCard(
        icon: Icons.logout_rounded,
        title: "Logout",
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
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.red,
              ),
        onTap: authController.isLoading.value
            ? null
            : () => _showLogoutDialog(context),
      ),
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
                  child: const Icon(
                    Icons.chat_bubble_rounded,
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
