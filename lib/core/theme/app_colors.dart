import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette (Teal / Mint theme)
  static const Color primary = Color(0xFF0D9488); // Teal 600
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryDark = Color(0xFF0F766E); // Teal 700
  static const Color primaryContainer = Color(0xFFCCFBF1); // Teal 100
  static const Color onPrimaryContainer = Color(0xFF115E59); // Teal 800

  // Background & Surface
  static const Color background = Color(0xFFF0FBF9); // Mint tint background
  static const Color surface = Color(0xFFFFFFFF); // Card white
  static const Color surfaceVariant = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100

  // Text
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textLight = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF16A34A); // Emerald green
  static const Color successLight = Color(0xFFDCFCE7); // Emerald 100
  static const Color successDark = Color(0xFF15803D);

  static const Color warning = Color(0xFFF59E0B); // Amber warning
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color warningDark = Color(0xFFB45309);

  static const Color danger = Color(0xFFDC2626); // Crimson red
  static const Color dangerLight = Color(0xFFFEE2E2); // Crimson 100
  static const Color dangerDark = Color(0xFFB91C1C);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100

  // Shadow
  static List<BoxShadow> get softShadow => [
        const BoxShadow(
          color: Color(0x0A0F172A),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x0D0D9488),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
        const BoxShadow(
          color: Color(0x05000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get alertShadow => [
        const BoxShadow(
          color: Color(0x1FDC2626),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];
}
