import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../profile/data/models/user_profile_entity.dart';

/// Greeting Header — Updated Design v2
/// الترحيب + الأفاتار على اليمين (RTL)
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    super.key,
    required this.greeting,
    required this.profile,
  });

  final String greeting;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ─── Avatar (يسار في RTL = يمين على الشاشة) ──────
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Container(
            width: AppConstants.avatarM,
            height: AppConstants.avatarM,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgDark,
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'أ',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: AppConstants.spaceM),

        // ─── Notification bell ────────────────────────────
        _IconBtn(icon: Icons.notifications_none_rounded, onTap: () {}),

        const Spacer(),

        // ─── Text (على اليمين — RTL) ──────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              greeting,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              '${profile.name} 💪',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, color: AppColors.textMuted, size: AppConstants.iconM),
      ),
    );
  }
}
