import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.name,
    this.avatarUrl,
  });

  final String  greeting;
  final String  name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: _HomeAvatar(name: name, avatarUrl: avatarUrl),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                color: context.colors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              '💪 $name',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: context.colors.textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Home Avatar ────────────────────────────────────────────
class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({required this.name, this.avatarUrl});
  final String  name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          width: 44.r, height: 44.r,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initials(context),
        ),
      );
    }
    return _initials(context);
  }

  Widget _initials(BuildContext context) => Container(
        width: 44.r, height: 44.r,
        decoration: BoxDecoration(
          color: context.colors.bgDark,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textOnDark,
          ),
        ),
      );
}
