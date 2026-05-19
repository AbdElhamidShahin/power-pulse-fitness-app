import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// Primary app bar widget — used on sub-screens.
///
/// Previously lib/view/wedget/custom appbar.dart (filename had a space!).
/// Renamed file to custom_app_bar.dart.  Both widgets preserved.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  const CustomAppBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AppBar(
        title: Text(text, style: AppTextStyles.appBarTitleSmall),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Secondary app bar — used on screens that need a back arrow.
///
/// Previously `class appbar` (lowercase) in the same file.
class SecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;

  const SecondaryAppBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AppBar(
        title: Text(text, style: AppTextStyles.appBarTitle),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
