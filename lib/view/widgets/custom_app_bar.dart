import 'package:flutter/material.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = AppColors.appBarCenterTitle,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: AppColors.appBarToolbarHeight,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading ?? (showBackButton ? const CustomBackButton() : null),
      title: Text(
        title,
        style: AppColors.appBarTitleStyle,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppColors.appBarToolbarHeight);
}
