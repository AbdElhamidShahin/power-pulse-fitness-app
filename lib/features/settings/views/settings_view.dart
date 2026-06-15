import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task/features/settings/views/widget/profile_card.dart';
import 'package:task/features/settings/views/widget/settings_item.dart';
import 'package:task/features/settings/views/widget/warning_dialog.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_card.dart';
import '../logic/cubit/settings_cubit.dart';
import '../logic/cubit/settings_states.dart';
import 'faq_page.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(),
      child: const _SettingsScreen(),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLaunchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, textDirection: TextDirection.rtl),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PpAppBar(title: 'الإعدادات', showNotification: false),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: AppSpacing.marginMobile,
              right: AppSpacing.marginMobile,
              top: AppSpacing.sm,
              bottom: AppSpacing.bottomNavHeight + AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SectionHeader(title: 'الإعدادات'),
                const SizedBox(height: AppSpacing.md),
                const ProfileCard(),
                const SizedBox(height: AppSpacing.md),
                const _SectionLabel('عام'),
                const SizedBox(height: AppSpacing.xs),
                SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  color: AppColors.primary,
                  title: 'سياسة الخصوصية',
                  onTap: () => context
                      .read<SettingsCubit>()
                      .launchUrl(AppConstants.privacyPolicyUrl),
                ),
                SettingsItem(
                  icon: Icons.star_outline_rounded,
                  color: AppColors.warning,
                  title: 'تقييم التطبيق',
                  onTap: () => context
                      .read<SettingsCubit>()
                      .launchUrl(AppConstants.playStoreUrl),
                ),
                SettingsItem(
                  icon: Icons.share_outlined,
                  color: AppColors.success,
                  title: 'مشاركة التطبيق',
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                const _SectionLabel('دعم'),
                const SizedBox(height: AppSpacing.xs),
                SettingsItem(
                  icon: Icons.help_outline_rounded,
                  color: AppColors.success,
                  title: 'أسئلة شائعة',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FAQPage()),
                  ),
                ),
                SettingsItem(
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                  title: 'تحذير',
                  onTap: () => showWarningDialog(context),
                  showArrow: false,
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text('Power Pulse v1.0.0',
                      style: AppTextStyles.labelMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: AppTextStyles.labelMuted.copyWith(letterSpacing: 1.5),
      );
}
