/// Application-wide constants: breakpoints, durations, dimensions.
class AppConstants {
  AppConstants._();

  // ── App Info ─────────────────────────────────────────────────────────
  static const String appName = 'AI PDF Summarizer';
  static const String appVersion = '1.0.0';

  // ── Responsive Breakpoints ───────────────────────────────────────────
  static const double mobileBreakpoint = 450;
  static const double tabletBreakpoint = 800;
  static const double desktopBreakpoint = 1200;

  // ── Layout Dimensions ────────────────────────────────────────────────
  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const double chatPanelWidth = 360.0;
  static const double maxContentWidth = 1400.0;

  // ── Animation Durations ──────────────────────────────────────────────
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration mockApiDelay = Duration(seconds: 2);

  // ── Padding & Spacing ────────────────────────────────────────────────
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // ── Border Radius ────────────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // ── Glass Effect ─────────────────────────────────────────────────────
  static const double glassBlurSigma = 10.0;
  static const double glassOpacity = 0.1;
  static const double glassBorderOpacity = 0.2;

  // ── Mock Data ────────────────────────────────────────────────────────
  static const int mockHistoryItemCount = 12;
  static const int mockChatMessageCount = 5;
}
