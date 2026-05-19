import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_utils.dart';
import 'bmi_calculator_screen.dart';
import 'food_details_screen.dart';
import 'ideal_weight_screen.dart';
import 'calorie_counter_screen.dart';

/// Tools tab — grid of calculator tools.
///
/// Previously lib/view/views/ToolsScreen.dart.
/// Updated imports to new feature paths; no layout/logic changes.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final itemHeight = (size.height - kToolbarHeight - 24) / 10;
    final itemWidth = size.width / 2;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 1,
          childAspectRatio: itemWidth / itemHeight,
          children: <Widget>[
            _buildToolCard(
              context,
              title: 'حساب مؤشر كتلة الجسم BMI',
              icon: Icons.fitness_center,
              targetPage: const BmiCalculatorScreen(),
            ),
            _buildToolCard(
              context,
              title: 'حساب تفاصيل الأطعمة',
              icon: Icons.food_bank,
              targetPage: FoodDetailsScreen(),
            ),
            _buildToolCard(
              context,
              title: 'حساب الوزن المثالي IBW',
              icon: Icons.scale,
              targetPage: Idelweight(),
            ),
            _buildToolCard(
              context,
              title: 'حساب السعرات الحرارية',
              icon: Icons.local_fire_department,
              targetPage: Culcolatecounting(),
            ),
          ].animate(interval: 300.ms).fadeIn(duration: 800.ms),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget targetPage,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
          context, NavigationUtils.fadeScaleRoute(targetPage)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.toolCardBackground,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.toolCardShadow,
              spreadRadius: 2,
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.toolCardTitle,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.start,
            ),
            const Spacer(),
            Icon(icon, size: 36, color: AppColors.toolCardText),
            const SizedBox(width: 10),
          ],
        ),
      ).animate().scale(duration: 500.ms, curve: Curves.easeOut),
    );
  }
}
