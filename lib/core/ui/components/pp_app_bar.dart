import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Context-aware app bar.
/// Home: transparent, just brand name — the hero card IS the header.
/// Sub-screens: opaque, back button, screen title.
class PpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PpAppBar({
    super.key,
    this.title = 'Power Pulse',
    this.showBack = false,
    this.showNotification = false,
    this.transparent = false,
    this.actions,
  });

  final String title;
  final bool showBack, showNotification, transparent;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: transparent
            ? Colors.transparent
            : AppColors.background,
        border: transparent
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppSpacing.appBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                // Left — back or notification
                if (showBack)
                  _iconBtn(context, Icons.arrow_back_ios_new_rounded,
                      () => Navigator.of(context).maybePop())
                else if (showNotification)
                  _iconBtn(context, Icons.notifications_outlined, null)
                else
                  const SizedBox(width: 40),

                if (actions != null) ...actions!,
                const Spacer(),

                // Right — brand name
                Text(title, style: AppTextStyles.appBarTitle),
                const SizedBox(width: AppSpacing.xs),
                _avatar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(
      BuildContext context, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 17),
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceHigh,
        border: Border.all(
            color: AppColors.primary.withOpacity(0.35), width: 1.5),
      ),
      child: const Icon(Icons.person_outline_rounded,
          color: AppColors.textSecondary, size: 18),
    );
  }
}

class PpBackBar extends StatelessWidget implements PreferredSizeWidget {
  const PpBackBar({super.key, required this.title});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) =>
      PpAppBar(title: title, showBack: true);
}
