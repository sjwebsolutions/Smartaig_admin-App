import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view/screens/banner_details_screen.dart';
import '../../view_models/getX/banner_controller.dart';
import '../../models/banner_model.dart';
import 'publish_banner_screen.dart';
import '../../utils/app_colors.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController controller = Get.put(BannerController());
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
                  "BANNERS",
                  style: AppColors.appBarTitleStyle,
                ),
              )
            : null,
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.banners.isEmpty) {
            return const Center(
              child: Text(
                "No Banners available",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchBanners(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              itemCount: controller.banners.length,
              itemBuilder: (context, index) {
                final banner = controller.banners[index];
                return Card(
                  color: AppColors.cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppColors.cardBorderRadius,
                    side: const BorderSide(
                      color: Color(0xFF0038A8),
                      width: 1.2,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (banner.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Container(
                            color: Colors
                                .grey[50], // Light background for non-filling images
                            child: Image.network(
                              banner.imageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    color: Colors.grey[100],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showToggleConfirmationDialog(
                                        context,
                                        controller,
                                        banner,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (banner.status == 1
                                                  ? Colors.green
                                                  : Colors.grey)
                                              .withAlpha(30),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          banner.status == 1
                                              ? "ACTIVE"
                                              : "INACTIVE",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: banner.status == 1
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Transform.scale(
                                      scale: 0.7,
                                      child: Switch(
                                        value: banner.status == 1,
                                        onChanged: (_) => _showToggleConfirmationDialog(
                                          context,
                                          controller,
                                          banner,
                                        ),
                                        activeColor: Colors.green,
                                        activeTrackColor: Colors.green
                                            .withAlpha(100),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 12,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      banner.publishedAt.split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              banner.bannerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0038A8).withAlpha(10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                banner.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0038A8),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, thickness: 0.5),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      _buildInfoItem(
                                        Icons.person_pin_rounded,
                                        banner.targetScope,
                                      ),
                                      _buildInfoItem(
                                        Icons.timer_rounded,
                                        "${banner.displayDays} Days",
                                      ),
                                      if (banner.targetedAudiences.isNotEmpty)
                                        _buildInfoItem(
                                          Icons.groups_rounded,
                                          banner.targetedAudiences.join(', '),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Get.to(
                                      () => BannerDetailsScreen(
                                        imageUrl: banner.imageUrl,
                                        title: banner.bannerName,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                      size: 18,
                                    ),
                                    label: const Text("View / Share"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: BorderSide(
                                        color: Colors.red.withAlpha(50),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: AppColors.buttonShape,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => Get.to(
                                      () => PublishBannerScreen(banner: banner),
                                    ),
                                    icon: const Icon(
                                      Icons.rocket_launch_rounded,
                                      size: 18,
                                    ),
                                    label: const Text("Release"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.buttonColor,
                                      foregroundColor: AppColors.buttonTextColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      elevation: 0,
                                      shape: AppColors.buttonShape,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
        ),
      ),
    );
  }

  void _showToggleConfirmationDialog(
    BuildContext context,
    BannerController controller,
    BannerModel banner,
  ) {
    final bool isActive = banner.status == 1;
    final String actionText = isActive ? "Deactivate" : "Activate";
    final Color actionColor = isActive ? const Color(0xFFEF4444) : Colors.green;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Colors.white,
              width: 1.8,
            ),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon Container
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: actionColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive
                        ? Icons.power_settings_new_rounded
                        : Icons.check_circle_rounded,
                    color: actionColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  "$actionText Banner?",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),

                // Content Description
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: "Are you sure you want to "),
                      TextSpan(
                        text: actionText.toLowerCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: actionColor,
                        ),
                      ),
                      const TextSpan(text: " the banner "),
                      TextSpan(
                        text: '"${banner.bannerName}"',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const TextSpan(text: "?"),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons Row: Cancel & Confirm
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Confirm Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          controller.toggleBannerStatus(banner.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "CONFIRM",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
