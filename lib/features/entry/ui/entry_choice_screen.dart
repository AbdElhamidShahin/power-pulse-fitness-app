import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/user_mode_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
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
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPaddingH + 4,
            vertical: AppConstants.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.space4XL),

              // ── Brand pill ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM,
                  vertical: AppConstants.spaceXXS + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusPill),
                ),
                child: Text(
                  'Power Pulse',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spaceM),

              Text(
                'مرحباً بك 👋',
                style: AppTextStyles.displayMedium.copyWith(
                  color: const Color(0xFFF5F5F0),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppConstants.spaceS),

              Text(
                'ابدأ رحلتك نحو اللياقة البدنية',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF6B6B6B),
                ),
              ),

              const Spacer(),

              // ── Account Card ────────────────────────────────────────
              _OptionCard(
                icon: Icons.cloud_done_rounded,
                iconColor: AppColors.accent,
                iconBg: AppColors.accentDim,
                title: 'إنشاء حساب / تسجيل الدخول',
                description:
                    'أنشئ حسابًا أو سجّل دخولك لحفظ بياناتك (الملف الشخصي، التقدم، التمارين، التغذية) بأمان على السحابة واستعادتها متى أعدت تثبيت التطبيق.',
                actionLabel: 'متابعة بحساب',
                onTap: () => context.go(AppRouter.login),
                isPrimary: true,
              ),

              const SizedBox(height: AppConstants.spaceL),

              // ── Guest Card ──────────────────────────────────────────
              _OptionCard(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF9CA3AF),
                iconBg: const Color(0xFF1F2937),
                title: 'متابعة كضيف',
                description:
                    'ستُحفظ بياناتك على هذا الجهاز فقط. يمكنك إنشاء حساب لاحقًا لحفظها على السحابة واستعادتها.',
                actionLabel: 'متابعة بدون حساب',
                onTap: () => _continueAsGuest(context),
                isPrimary: false,
              ),

              const SizedBox(height: AppConstants.space3XL),
            ],
          ),
        ),
      ),
    );
  }
}

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
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isPrimary ? AppColors.accent.withOpacity(0.4) : const Color(0xFF2A2A2A),
          width: isPrimary ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(icon, color: iconColor, size: AppConstants.iconM),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: const Color(0xFFF5F5F0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF6B6B6B),
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXL),
          SizedBox(
            width: double.infinity,
            child: isPrimary
                ? PPButton(label: actionLabel, onPressed: onTap)
                : OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3A3A3A)),
                      foregroundColor: const Color(0xFF9CA3AF),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.spaceM),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                    child: Text(actionLabel,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: const Color(0xFF9CA3AF))),
                  ),
          ),
        ],
      ),
    );
  }
}
