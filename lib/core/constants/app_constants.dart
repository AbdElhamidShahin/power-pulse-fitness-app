
abstract class AppConstants {
  AppConstants._();

  // ─── Spacing ───────────────────────────────────────────────
  static const double spaceXXS =  2.0;
  static const double spaceXS  =  4.0;
  static const double spaceS   =  8.0;
  static const double spaceM   = 12.0;
  static const double spaceL   = 16.0;
  static const double spaceXL  = 20.0;
  static const double spaceXXL = 24.0;
  static const double space3XL = 32.0;
  static const double space4XL = 40.0;
  static const double space5XL = 48.0;

  // ─── Border Radius ─────────────────────────────────────────
  static const double radiusXS   =  6.0;
  static const double radiusS    = 10.0;
  static const double radiusM    = 14.0;
  static const double radiusL    = 18.0;
  static const double radiusXL   = 24.0;
  static const double radiusXXL  = 32.0;
  static const double radiusPill = 100.0;

  // ─── Screen Padding ────────────────────────────────────────
  static const double screenPaddingH = 18.0; // horizontal
  static const double screenPaddingV = 16.0; // vertical

  // ─── Component Sizes ───────────────────────────────────────
  // Buttons
  static const double buttonHeightLarge  = 52.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightSmall  = 36.0;

  // Icons
  static const double iconXS = 14.0;
  static const double iconS  = 18.0;
  static const double iconM  = 22.0;
  static const double iconL  = 28.0;
  static const double iconXL = 36.0;

  // Avatars
  static const double avatarS  = 32.0;
  static const double avatarM  = 42.0;
  static const double avatarL  = 56.0;
  static const double avatarXL = 80.0;

  // Cards
  static const double cardHeightHero  = 180.0;
  static const double cardHeightSmall = 100.0;
  static const double exerciseThumb   =  56.0;

  // Bottom Nav
  static const double bottomNavHeight = 64.0;

  // ─── Elevation / Blur ──────────────────────────────────────
  static const double blurGlass  = 12.0;
  static const double blurLight  =  6.0;

  // ─── Animation Durations ───────────────────────────────────
  static const Duration durationFast   = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow   = Duration(milliseconds: 400);
  static const Duration durationPage   = Duration(milliseconds: 300);

  // ─── API ───────────────────────────────────────────────────
  static const int apiTimeoutSeconds   = 15;
  static const int apiCacheDays        =  1;

  // ─── Pagination ────────────────────────────────────────────
  static const int pageSize = 20;
}
