import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated gradient background shared by all auth screens.
/// Dark base with subtle neon green radial accents.
class AuthGradientBackground extends StatelessWidget {
  const AuthGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBg,
            Color(0xFF0D1117),
            AppColors.darkSurface,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // ── Top-right green glow ──────────────────────────────────
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── Bottom-left green glow ────────────────────────────────
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonGreen.withValues(alpha: 0.06),
                    AppColors.neonGreen.withValues(alpha: 0.01),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // ── Center subtle accent ──────────────────────────────────
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.3,
            left: MediaQuery.sizeOf(context).width * 0.5 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          child,
        ],
      ),
    );
  }
}
