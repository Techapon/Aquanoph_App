import 'package:flutter/material.dart';

/// Tokens from docs/DESIGN_TOKENS.md (Figma "NamDee" file).
abstract final class AppColors {
  static const textPrimary = Color(0xFF232323);
  static const textSecondary = Color(0xFF707070);
  static const textMuted = Color(0xFF6A6A6A);
  static const textHint = Color(0xFFB3B3B3); // input placeholder (add-pond Input)

  static const fillReadonly = Color(0xD9F4F4F4); // rgba(244,244,244,0.85) read-only field
  static const darkButton = Color(0xFF2A2A2A); // wizard "Next" solid button

  static const optimal = Color(0xFF0BE220);
  static const stress = Color(0xFFFFCC00);
  static const success = Color(0xFF11CD24); // 109:1176 tick stroke
  static const successBg = Color(0xFFEEFFF6); // 109:1176 tick circle fill
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

  // ponds LIST frame (figma/pond_page/Ponds.css, "Ponds") — DO/Warning cards & divider
  static const listOptimalBg = Color(0xFFECFFEE); // DO card fill
  static const listOptimalBorder = Color(0xFF38E849); // DO card border
  static const warnTitle = Color(0xFFFF7373); // "Warning" text
  static const warnIcon = Color(0xFFFF8D8D); // triangle-alert stroke
  static const dividerLight = Color(0xFFF4F4F4); // Line 4 block divider

  // [A] no Figma variants exported yet (figma/README ⏳ row) — derived until confirmed:
  static const critical = Color(0xFFFF3232); // solid version of zoneCritical
  static const listStressBg = Color(0xFFFFF7DE); // tint of stress yellow
}
