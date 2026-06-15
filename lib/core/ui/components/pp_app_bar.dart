import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PpAppBar({
    super.key,
    required this.title,
    this.showNotification = false,
    this.transparent = false,
  });

  final String title;
  final bool showNotification;
  final bool transparent;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent ? Colors.transparent : AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Text(title, style: AppTextStyles.appBarTitle),
      actions: showNotification
          ? [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ]
          : null,
    );
  }
}

class PpBackBar extends StatelessWidget implements PreferredSizeWidget {
  const PpBackBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Text(title, style: AppTextStyles.appBarTitleSmall),
      leading: IconButton(
        icon: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textPrimary),
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }
}
