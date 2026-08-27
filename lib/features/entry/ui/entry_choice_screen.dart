import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/user_mode_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/pp_logo.dart';

const _kBg        = Color(0xFF0F0F0F);
const _kSurface   = Color(0xFF1A1A1A);
const _kSurface2  = Color(0xFF232323);
const _kBorder    = Color(0xFF2E2E2E);
const _kAccent    = Color(0xFFA8E063);
const _kAccentDim = Color(0x26A8E063);
const _kTextHigh  = Color(0xFFFFFFFF);
const _kTextMid   = Color(0xFFAAAAAA);
const _kTextLow   = Color(0xFF555555);

class EntryChoiceScreen extends StatefulWidget {
  const EntryChoiceScreen({super.key});
  @override
  State<EntryChoiceScreen> createState() => _EntryChoiceScreenState();
}

class _EntryChoiceScreenState extends State<EntryChoiceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _fade;
  late final Animation<Offset>    _slide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:     Brightness.dark,
    ));
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _continueAsGuest(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await UserModeService.setGuest(prefs);
    AppRouter.clearLocationCache();
    if (context.mounted) context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spaceXXL),

                  // Logo row
                  Row(children: [
                    const PPLogo(size: 40),
                    const SizedBox(width: AppConstants.spaceS),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text(AppStrings.appName,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 17,
                          fontWeight: FontWeight.w900, color: _kTextHigh,
                          letterSpacing: 0.2)),
                      const Text(AppStrings.appTagline,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                          color: _kAccent, fontWeight: FontWeight.w600)),
                    ]),
                  ]),

                  const Spacer(flex: 2),

                  // Headline
                  const Text(
                    AppStrings.entryTitle,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 34,
                      fontWeight: FontWeight.w900, color: _kTextHigh,
                      height: 1.1, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: AppConstants.spaceS),
                  const Text(
                    AppStrings.entryDataSaved,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                      color: _kAccent, fontWeight: FontWeight.w600),
                  ),

                  const Spacer(flex: 3),

                  // Account card
                  _EntryCard(
                    icon: Icons.cloud_done_rounded,
                    iconColor: _kAccent, iconBg: _kAccentDim,
                    title: AppStrings.entryAccountTitle,
                    subtitle: AppStrings.entryAccountSub,
                    buttonLabel: AppStrings.entryAccountBtn,
                    isPrimary: true,
                    onTap: () => context.go(AppRouter.login),
                    perks: const [
                      AppStrings.entryPerk1,
                      AppStrings.entryPerk2,
                      AppStrings.entryPerk3,
                    ],
                  ),

                  const SizedBox(height: AppConstants.spaceL),

                  // Guest card
                  _EntryCard(
                    icon: Icons.person_outline_rounded,
                    iconColor: _kTextMid, iconBg: _kSurface2,
                    title: AppStrings.entryGuestTitle,
                    subtitle: AppStrings.entryGuestSub,
                    buttonLabel: AppStrings.entryGuestBtn,
                    isPrimary: false,
                    onTap: () => _continueAsGuest(context),
                    perks: null,
                  ),

                  const Spacer(flex: 2),

                  Center(
                    child: const Text(
                      AppStrings.entryTerms,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: _kTextLow),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.title, required this.subtitle, required this.buttonLabel,
    required this.isPrimary, required this.onTap, required this.perks,
  });
  final IconData icon;
  final Color iconColor, iconBg;
  final String title, subtitle, buttonLabel;
  final bool isPrimary;
  final VoidCallback onTap;
  final List<String>? perks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isPrimary ? _kAccent.withOpacity(0.5) : _kBorder,
          width: isPrimary ? 1.5 : 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Icon + title + badge
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconBg,
                borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            child: Icon(icon, color: iconColor, size: AppConstants.iconM),
          ),
          const SizedBox(width: AppConstants.spaceM),
          Expanded(child: Text(title,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
              fontWeight: FontWeight.w700, color: _kTextHigh))),
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kAccentDim,
                borderRadius: BorderRadius.circular(AppConstants.radiusPill),
              ),
              child: const Text(AppStrings.entryAccountBadge,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
                    color: _kAccent, fontWeight: FontWeight.w700)),
            ),
        ]),

        const SizedBox(height: AppConstants.spaceM),
        Text(subtitle,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
              color: _kTextMid, height: 1.6)),

        if (perks != null) ...[
          const SizedBox(height: AppConstants.spaceM),
          ...perks!.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(children: [
              const Icon(Icons.check_rounded, color: _kAccent, size: 13),
              const SizedBox(width: 6),
              Text(p, style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: 11, color: _kTextMid)),
            ]),
          )),
        ],

        const SizedBox(height: AppConstants.spaceXL),

        // CTA button
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: AppConstants.buttonHeightMedium,
            decoration: BoxDecoration(
              color: isPrimary ? _kAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: isPrimary ? null : Border.all(color: _kBorder),
            ),
            child: Center(child: Text(buttonLabel,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isPrimary ? const Color(0xFF0F0F0F) : _kTextMid))),
          ),
        ),
      ]),
    );
  }
}
