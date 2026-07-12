import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../profile/data/models/user_profile_entity.dart';

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
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                'أهلاً، ${profile.name} 👋',
                style: Theme.of(context).textTheme.headlineLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spaceM),
        Row(
          children: [
            // Notification bell
            _IconBtn(
              icon: Icons.notifications_none_rounded,
              onTap: () {},
            ),
            const SizedBox(width: AppConstants.spaceS),
            // Avatar → profile
            GestureDetector(
              onTap: () => context.go('/profile'),
              child: Container(
                width: AppConstants.avatarM,
                height: AppConstants.avatarM,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgElevated,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
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
