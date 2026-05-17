import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/theme_provider.dart';

import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce minimum window size for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(450, 600),
      center: true,
      title: 'AI PDF Summarizer',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    const ProviderScope(
      child: AiSummarizerApp(),
    ),
  );
}

/// Root application widget.
class AiSummarizerApp extends ConsumerWidget {
  const AiSummarizerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ── Routing ────────────────────────────────────────────────────
      routerConfig: AppRouter.router,

      // ── Responsive Breakpoints ─────────────────────────────────────
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(
            start: 0,
            end: AppConstants.mobileBreakpoint,
            name: MOBILE,
          ),
          const Breakpoint(
            start: AppConstants.mobileBreakpoint + 1,
            end: AppConstants.tabletBreakpoint,
            name: TABLET,
          ),
          const Breakpoint(
            start: AppConstants.tabletBreakpoint + 1,
            end: AppConstants.desktopBreakpoint,
            name: 'TABLET_LANDSCAPE',
          ),
          const Breakpoint(
            start: AppConstants.desktopBreakpoint + 1,
            end: double.infinity,
            name: DESKTOP,
          ),
        ],
      ),
    );
  }
}
