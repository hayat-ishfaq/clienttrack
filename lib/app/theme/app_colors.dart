import 'package:flutter/material.dart';

/// Design tokens for ClientTrack's curated color system.
/// Defined in docs/FRONTEND_SPEC.md.
class AppColors {
  AppColors._();

  // Primary Brand Greens
  static const Color primaryForest = Color(0xFF2E5D31);
  static const Color midGreen = Color(0xFF5B8F4F);
  static const Color accentTealGreen = Color(0xFF3FAE7C);
  static const Color deepTeal = Color(0xFF2F7A6A);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F4F1);
  static const Color border = Color(0xFFE1E8E2);

  // Typography & Content
  static const Color textPrimary = Color(0xFF1B2A1E);
  static const Color textSecondary = Color(0xFF6B7A6E);
  static const Color textTertiary = Color(0xFF9BA89E);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Semantic Status Tones
  static const Color overdueRed = Color(0xFFD64545);
  static const Color overdueRedBg = Color(0xFFFDEEEE);

  static const Color dueSoonAmber = Color(0xFFE0A030);
  static const Color dueSoonAmberBg = Color(0xFFFEF8EC);

  static const Color paidTeal = Color(0xFF3FAE7C);
  static const Color paidTealBg = Color(0xFFE8F7F0);

  static const Color sentBlue = Color(0xFF4A6FA5);
  static const Color sentBlueBg = Color(0xFFEEF3F8);

  static const Color draftGrey = Color(0xFF6B7A6E);
  static const Color draftGreyBg = Color(0xFFF0F3F0);

  // Pro & Premium Accents
  static const Color goldPro = Color(0xFFD4AF37);
  static const Color goldProBg = Color(0xFFFBF7EB);
}
