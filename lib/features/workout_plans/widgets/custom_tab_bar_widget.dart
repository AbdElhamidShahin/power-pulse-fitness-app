import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../exercises/views/muscle_group_add_screen.dart';

class CustomTabBarDemo extends StatelessWidget {
  CustomTabBarDemo({super.key, required this.pageId});
  final String pageId;

  final int pageCount = 6;
  late final PageController _controller = PageController(initialPage: 0);
  final CustomTabBarController _tabBarController = CustomTabBarController();

  static const _tabTitles = ['صدر', 'ظهر', 'أكتاف', 'يدين', 'أرجل', 'بطن'];

  Widget _tabChild(BuildContext context, int index) {
    return TabBarItem(
      transform: ColorsTransform(
        highlightColor: AppColors.textPrimary,
        normalColor: AppColors.textSecondary,
        builder: (context, color) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          alignment: Alignment.center,
          constraints: const BoxConstraints(minWidth: 80),
          child: Text(_tabTitles[index],
            style: AppTextStyles.bodyMd.copyWith(color: color, fontWeight: FontWeight.w700)),
        ),
      ),
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpBackBar(title: 'إضافة تمارين'),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CustomTabBar(
              tabBarController: _tabBarController,
              height: 44,
              itemCount: pageCount,
              builder: _tabChild,
              indicator: RoundIndicator(
                color: AppColors.primary,
                top: 2, bottom: 2, left: 2, right: 2,
                radius: BorderRadius.circular(10),
              ),
              pageController: _controller,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pageCount,
              itemBuilder: (context, index) => _PageItem(index: index, pageId: pageId),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageItem extends StatelessWidget {
  const _PageItem({required this.index, required this.pageId});
  final int index;
  final String pageId;

  @override
  Widget build(BuildContext context) {
    const pages = [
      ('chest', 'تمارين الصدر'),
      ('lates', 'تمارين الظهر'),
      ('shorter', 'تمارين الكتف'),
      ('hands', 'تمارين الذراع'),
      ('legs', 'تمارين الأرجل'),
      ('beily', 'تمارين البطن'),
    ];
    return MuscleGroupAddScreen(pageId: pages[index].$1, title: pages[index].$2);
  }
}
