import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_card.dart';
import 'faq_page.dart';
import '../../workout_plans/views/choose_workout_system_screen.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpAppBar(title: 'الإعدادات', showNotification: false),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: AppSpacing.marginMobile, right: AppSpacing.marginMobile,
            top: AppSpacing.sm, bottom: AppSpacing.bottomNavHeight + AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SectionHeader(title: 'الإعدادات'),
              const SizedBox(height: AppSpacing.md),

              // ── Profile card ──────────────────────────────────────────
              _ProfileCard(),
              const SizedBox(height: AppSpacing.md),

              _SectionLabel('عام'),
              const SizedBox(height: AppSpacing.xs),
              _Item(icon: Icons.privacy_tip_outlined, color: AppColors.primary, title: 'سياسة الخصوصية',
                onTap: () => _launch(AppConstants.privacyPolicyUrl)),
              _Item(icon: Icons.star_outline_rounded, color: AppColors.warning, title: 'تقييم التطبيق',
                onTap: () => _launch(AppConstants.playStoreUrl)),
              _Item(icon: Icons.share_outlined, color: AppColors.success, title: 'مشاركة التطبيق',
                onTap: () {}),

              const SizedBox(height: AppSpacing.sm),
              _SectionLabel('دعم'),
              const SizedBox(height: AppSpacing.xs),
              _Item(icon: Icons.help_outline_rounded, color: AppColors.success, title: 'أسئلة شائعة',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FAQPage()))),
              _Item(icon: Icons.warning_amber_rounded, color: AppColors.error, title: 'تحذير',
                onTap: () => _warningDialog(context), showArrow: false),

              const SizedBox(height: AppSpacing.lg),
              Center(child: Text('Power Pulse v1.0.0', style: AppTextStyles.labelMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launch(String url) async => launchUrl(Uri.parse(url));

  void _warningDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      title: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('تحذير', style: AppTextStyles.headlineMd.copyWith(color: AppColors.error)),
        const SizedBox(width: 8),
        const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
      ]),
      content: Text('هذه التمارين لأغراض تثقيفية فقط. استشر طبيبك قبل البدء في أي برنامج رياضي.',
        style: AppTextStyles.bodyMd, textDirection: TextDirection.rtl),
      actions: [TextButton(onPressed: () => Navigator.pop(context),
        child: Text('موافق', style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary, fontSize: 14)))],
    ),
  );
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => PpCard(
    borderColor: AppColors.primary.withOpacity(0.2),
    padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
    child: Row(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('المستوى', style: AppTextStyles.labelMuted),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Text('متوسط', style: AppTextStyles.labelCaps.copyWith(color: AppColors.success)),
          ),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceHigh,
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.person_outline_rounded, color: AppColors.outline, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            'المستخدم',
            style: AppTextStyles.headingSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Power Pulse User',
            style: AppTextStyles.labelMuted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) =>
    Text(label, style: AppTextStyles.labelMuted.copyWith(letterSpacing: 1.5));
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.color, required this.title, required this.onTap, this.showArrow = true});
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: PpCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm + 2),
      child: Row(
        children: [
          if (showArrow) Directionality(textDirection: TextDirection.rtl, child: Icon(Icons.chevron_right_rounded, size: 13, color: AppColors.outline)),
          const Spacer(),
          Text(title, style: AppTextStyles.headingSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    ),
  );
}
