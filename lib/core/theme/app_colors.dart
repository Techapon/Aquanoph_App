import 'package:flutter/material.dart';

/// Tokens from docs/DESIGN_TOKENS.md (Figma "NamDee").
abstract final class AppColors {
  static const textPrimary = Color(0xFF232323);
  static const textSecondary = Color(0xFF707070);
  static const textMuted = Color(0xFF6A6A6A);
  static const textHint = Color(0xFFB3B3B3); // input placeholder (add-pond Input)

  static const fillReadonly = Color(0xD9F4F4F4); // rgba(244,244,244,0.85) read-only field
  static const darkButton = Color(0xFF2A2A2A); // wizard "Next" solid button

  static const optimal = Color(0xFF0BE220);
  static const stress = Color(0xFFFFCC00);
  static const gradientStart = Color(0xFF0496FF);
  static const gradientEnd = Color(0xFF7ED348);

  static const urgentBg = Color(0xFFFFF0F0);
  static const urgentBorder = Color(0xFFF29E9F);
  static const warningBg = Color(0xFFFFF7F0);
  static const warningBorder = Color(0xFFEEA882);
  static const danger = Color(0xFFFF383C);
  static const neutralBorder = Color(0xFFD9D9D9);

  static const zoneOptimal = Color(0x1A0BE220); // 10% optimal green
  static const zoneCritical = Color(0x1AFF3232); // 10% critical red
}
