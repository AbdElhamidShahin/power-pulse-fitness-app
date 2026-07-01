import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';


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
