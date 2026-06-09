import 'package:flutter/material.dart';

/// Centralized app colors that adapt to light/dark mode.
/// Usage: `final c = AppColors.of(context);`
class AppColors {
  final Brightness brightness;

  AppColors._(this.brightness);

  factory AppColors.of(BuildContext context) {
    return AppColors._(Theme.of(context).brightness);
  }

  bool get isDark => brightness == Brightness.dark;

  // ─── Primary Brand ────────────────────────────────────────────────
  Color get primary => const Color(0xFF006C49);
  Color get primaryGreen => const Color(0xFF10A87A);
  Color get primaryContainer => const Color(0xFF10B981);
  Color get onPrimaryContainer => isDark ? const Color(0xFF6FFBBE) : const Color(0xFF00422B);
  Color get primaryFixed => const Color(0xFF6FFBBE);
  Color get onPrimaryFixedVariant => const Color(0xFF005236);

  // ─── Surfaces ─────────────────────────────────────────────────────
  Color get surface => isDark ? const Color(0xFF161D19) : const Color(0xFFF4FBF4);
  Color get surfaceBright => isDark ? const Color(0xFF1E2B22) : const Color(0xFFF4FBF4);
  Color get background => isDark ? const Color(0xFF161D19) : const Color(0xFFF3FAF6);
  Color get scaffoldBg => isDark ? const Color(0xFF161D19) : const Color(0xFFF3FAF6);
  Color get neutralSurface => isDark ? const Color(0xFF1A2420) : const Color(0xFFF8FAFC);
  Color get surfaceContainerLowest => isDark ? const Color(0xFF1E2B22) : const Color(0xFFFFFFFF);
  Color get surfaceContainerLow => isDark ? const Color(0xFF232D28) : const Color(0xFFEEF6EE);
  Color get surfaceContainer => isDark ? const Color(0xFF283530) : const Color(0xFFE8F0E9);
  Color get surfaceContainerHigh => isDark ? const Color(0xFF2E3D36) : const Color(0xFFE3EAE3);
  Color get surfaceContainerHighest => isDark ? const Color(0xFF3A4A42) : const Color(0xFFDDE4DD);

  // ─── On Surface / Text ────────────────────────────────────────────
  Color get onSurface => isDark ? const Color(0xFFE3EAE3) : const Color(0xFF161D19);
  Color get onSurfaceVariant => isDark ? const Color(0xFFBBCABF) : const Color(0xFF3C4A42);
  Color get darkText => isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937);
  Color get greyText => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

  // ─── Outline ──────────────────────────────────────────────────────
  Color get outline => isDark ? const Color(0xFF8A9A8F) : const Color(0xFF6C7A71);
  Color get outlineVariant => isDark ? const Color(0xFF3C4A42) : const Color(0xFFBBCABF);

  // ─── Cards / Containers ───────────────────────────────────────────
  Color get cardColor => isDark ? const Color(0xFF1E2B22) : Colors.white;
  Color get cardBorder => isDark ? const Color(0xFF3C4A42) : const Color(0xFFBBCABF);
  Color get gridCardBg => isDark ? const Color(0xFF1E3A2A) : const Color(0xFFE5EFE9);

  // ─── Semantic ─────────────────────────────────────────────────────
  Color get statusSuccess => const Color(0xFF10B981);
  Color get statusWarning => const Color(0xFFF59E0B);
  Color get statusCritical => const Color(0xFFEF4444);
  Color get profitGold => const Color(0xFFD4AF37);
  Color get tertiary => const Color(0xFFA43A3A);
  Color get tertiaryContainer => isDark ? const Color(0xFF711419) : const Color(0xFFFC7C78);
  Color get onTertiaryContainer => isDark ? const Color(0xFFFC7C78) : const Color(0xFF711419);

  // ─── Secondary ────────────────────────────────────────────────────
  Color get secondary => const Color(0xFF006398);
  Color get secondaryContainer => const Color(0xFF5BB8FE);
  Color get onSecondaryContainer => isDark ? const Color(0xFFCCE5FF) : const Color(0xFF00476E);

  // ─── Piutang / Receivables ────────────────────────────────────────
  Color get piutangBg => isDark ? const Color(0xFF3B1C1E) : const Color(0xFFFFE4E6);
  Color get piutangText => isDark ? const Color(0xFFFF8A8A) : const Color(0xFFBE123C);
  Color get piutangButton => isDark ? const Color(0xFFD44040) : const Color(0xFFBE123C);

  // ─── BottomNav ────────────────────────────────────────────────────
  Color get navBarBg => isDark ? const Color(0xFF1E2B22) : surface;
  Color get navIndicator => primaryGreen.withValues(alpha: 0.2);
}
