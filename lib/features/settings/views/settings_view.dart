import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import 'faq_page.dart';

/// Settings tab.
///
/// Previously lib/view/views/Setings.dart — same logic, updated imports & URLs
/// now use AppConstants instead of hardcoded strings.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOption(context,
              icon: Icons.privacy_tip,
              title: 'سياسة الخصوصية',
              onPressed: () => _launchUrl(AppConstants.privacyPolicyUrl)),
          _buildOption(context,
              icon: Icons.star,
              title: 'تقييم التطبيق',
              onPressed: () => _launchUrl(AppConstants.playStoreUrl)),
          _buildOption(context,
              icon: Icons.share,
              title: 'مشاركة',
              onPressed: () {}),
          _buildOption(context,
              icon: Icons.warning,
              title: 'تحذير',
              onPressed: () => _showWarningDialog(context)),
          _buildOption(context,
              icon: Icons.question_answer_sharp,
              title: 'أسئلة شائعة',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>  FAQPage()))),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onPressed}) {
    return Card(
      color: Colors.white60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, color: AppColors.primary, size: 28),
        title:
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.primary),
        onTap: onPressed,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تحذير',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        content: const Text('هذه رسالة تحذير.',
            style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
