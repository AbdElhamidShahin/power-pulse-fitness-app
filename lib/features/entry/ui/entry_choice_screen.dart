import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/user_mode_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pp_button.dart';

class EntryChoiceScreen extends StatelessWidget {
  const EntryChoiceScreen({super.key});

  Future<void> _continueAsGuest(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await UserModeService.setGuest(prefs);
    if (context.mounted) context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH + 4,
            vertical:   AppConstants.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // ── App icon + brand ──────────────────────────────
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color:        AppColors.accentDim,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.accent,
                  size:  AppConstants.iconXL,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXL),

              Text(
                'مرحباً بك 👋',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppConstants.spaceS),
              Text(
                'ابدأ رحلتك نحو اللياقة البدنية',
                style: AppTextStyles.bodyMedium,
              ),

              const Spacer(flex: 3),

              // ── Account card ──────────────────────────────────
              _OptionCard(
                icon:        Icons.cloud_done_rounded,
                iconColor:   AppColors.accent,
                iconBg:      AppColors.accentDim,
                title:       'إنشاء حساب / تسجيل الدخول',
                description: 'أنشئ حسابًا لحفظ بياناتك على السحابة واستعادتها '
                    'في أي وقت على أي جهاز.',
                actionLabel: 'متابعة بحساب',
                onTap:       () => context.go(AppRouter.login),
                isPrimary:   true,
              ),

              const SizedBox(height: AppConstants.spaceL),

              // ── Guest card ────────────────────────────────────
              _OptionCard(
                icon:        Icons.person_outline_rounded,
                iconColor:   AppColors.textMuted,
                iconBg:      AppColors.bgElevated,
                title:       'متابعة كضيف',
                description: 'ستُحفظ بياناتك على هذا الجهاز فقط. '
                    'يمكنك إنشاء حساب لاحقًا.',
                actionLabel: 'متابعة بدون حساب',
                onTap:       () => _continueAsGuest(context),
                isPrimary:   false,
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Option Card ──────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
    required this.isPrimary,
  });

  final IconData icon;
  final Color    iconColor;
  final Color    iconBg;
  final String   title;
  final String   description;
  final String   actionLabel;
  final VoidCallback onTap;
  final bool     isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      decoration: BoxDecoration(
        color:        AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isPrimary
              ? AppColors.accent.withOpacity(0.4)
              : AppColors.borderSubtle,
          width: isPrimary ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color:        iconBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(icon, color: iconColor, size: AppConstants.iconM),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Text(title, style: AppTextStyles.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppConstants.spaceXL),
          SizedBox(
            width: double.infinity,
            child: isPrimary
                ? PPButton(label: actionLabel, onPressed: onTap)
                : OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderMedium),
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spaceM),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                    child: Text(actionLabel,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        )),
                  ),
          ),
        ],
      ),
    );
  }
}
