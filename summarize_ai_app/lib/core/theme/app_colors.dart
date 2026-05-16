import 'package:flutter/material.dart';

/// Centralized color palette for the AI PDF Summarizer app.
/// Design style: AI SaaS, dark mode, green neon accent, glassmorphism.
class AppColors {
  AppColors._();

  // ── Primary Accent (Green Neon) ──────────────────────────────────────
  static const Color primary = Color(0xFF00E676);
  static const Color primaryLight = Color(0xFF69F0AE);
  static const Color primaryDark = Color(0xFF00C853);
  static const Color neonGreen = Color(0xFF39FF14);

  // ── Gradient Colors ──────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFF00E676);
  static const Color gradientEnd = Color(0xFF00BFA5);
  static const Color gradientDark = Color(0xFF004D40);

  // ── Background ───────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkElevated = Color(0xFF1E1E3A);
  static const Color darkSidebar = Color(0xFF0F0F23);

  // ── Light Theme (Optional) ───────────────────────────────────────────
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F3F5);

  // ── Text Colors ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color textOnPrimary = Color(0xFF0A0A0A);

  // ── Glass / Overlay ──────────────────────────────────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassOverlay = Color(0x0DFFFFFF);

  // ── Status Colors ────────────────────────────────────────────────────
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFD740);
  static const Color info = Color(0xFF448AFF);

  // ── Divider / Border ─────────────────────────────────────────────────
  static const Color divider = Color(0xFF2A2A3E);
  static const Color border = Color(0xFF2E2E4A);

  // ── Chat Bubble Colors ───────────────────────────────────────────────
  static const Color userBubble = Color(0xFF00E676);
  static const Color aiBubble = Color(0xFF1E1E3A);

  // ── Gradients ────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBg, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonGreen, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [darkSidebar, Color(0xFF0D0D1F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
