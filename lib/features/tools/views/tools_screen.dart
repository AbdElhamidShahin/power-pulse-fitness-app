import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_card.dart';
import 'bmi_calculator_screen.dart';
import 'food_details_screen.dart';
import 'ideal_weight_screen.dart';
import 'calorie_counter_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const _tools = [
    _Tool('حساب مؤشر كتلة الجسم', 'BMI Calculator', Icons.monitor_weight_outlined, AppColors.primary, 0),
    _Tool('حساب تفاصيل الأطعمة', 'Food Details', Icons.restaurant_menu_outlined, AppColors.success, 1),
    _Tool('حساب الوزن المثالي', 'Ideal Body Weight', Icons.scale_outlined, AppColors.warning, 2),
    _Tool('حساب السعرات الحرارية', 'Calorie Counter', Icons.local_fire_department_outlined, AppColors.error, 3),
  ];

  Widget _page(int idx) {
    switch (idx) {
      case 0: return const BmiCalculatorScreen();
      case 1: return FoodDetailsScreen();
      case 2: return Idelweight();
      default: return const Culcolatecounting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpAppBar(title: 'الأدوات', showNotification: false),
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
              SectionHeader(title: 'الأدوات'),
              const SizedBox(height: 4),
              Text('حاسبات اللياقة البدنية', style: AppTextStyles.bodyMuted),
              const SizedBox(height: AppSpacing.md),
              ...List.generate(_tools.length, (i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _ToolCard(
                  tool: _tools[i],
                  onTap: () => Navigator.push(context, _route(_page(i))),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  PageRoute _route(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, a, __, child) =>
        FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), child: child)),
    transitionDuration: const Duration(milliseconds: 280),
  );
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool, required this.onTap});
  final _Tool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PpCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Row(
        children: [
          Directionality(textDirection: TextDirection.rtl, child: Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 14)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tool.title, style: AppTextStyles.headingSmall),
              const SizedBox(height: 3),
              Text(tool.subtitle, style: AppTextStyles.labelMuted),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: tool.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: tool.color.withOpacity(0.3), width: 1),
            ),
            child: Icon(tool.icon, color: tool.color, size: 24),
          ),
        ],
      ),
    );
  }
}

class _Tool {
  const _Tool(this.title, this.subtitle, this.icon, this.color, this.index);
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final int index;
}
