import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightBgMain = Color(0xFFF4F7F9);
  static const Color lightBgSurface = Color(0xFFFFFFFF);
  static const Color lightBgSurfaceHover = Color(0xFFF1F5F9);
  static const Color lightTextMain = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightPrimary = Color(0xFF1D4ED8);
  static const Color lightPrimaryHover = Color(0xFF1E40AF);
  static const Color lightPrimaryLight = Color(0x1A1D4ED8); // 10% opacity
  static const Color lightSecondary = Color(0xFF475569);
  static const Color lightBorderColor = Color(0xFFE2E8F0);

  // Dark Theme Colors
  static const Color darkBgMain = Color(0xFF0B1120);
  static const Color darkBgSurface = Color(0xFF1E293B);
  static const Color darkBgSurfaceHover = Color(0xFF334155);
  static const Color darkTextMain = Color(0xFFF8FAFC);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkPrimary = Color(0xFF3B82F6);
  static const Color darkPrimaryHover = Color(0xFF60A5FA);
  static const Color darkPrimaryLight = Color(0x263B82F6); // 15% opacity
  static const Color darkSecondary = Color(0xFF94A3B8);
  static const Color darkBorderColor = Color(0xFF334155);

  // Accent Colors (Shared or slightly tweaked, here shared for simplicity as per CSS)
  static const Color accentRed = Color(0xFFE11D48);
  static const Color accentGreen = Color(0xFF059669);
  static const Color accentYellow = Color(0xFFD97706);

  // Shadows
  static const List<BoxShadow> lightShadowSm = [
    BoxShadow(color: Color(0x08000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  static const List<BoxShadow> lightShadowMd = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
  ];
  static const List<BoxShadow> lightShadowLg = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 10), blurRadius: 15, spreadRadius: -3),
    BoxShadow(color: Color(0x08000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -4),
  ];

  static const List<BoxShadow> darkShadowMd = [
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
  ];
  static const List<BoxShadow> darkShadowLg = [
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 10), blurRadius: 15, spreadRadius: -3),
    BoxShadow(color: Color(0x80000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -4),
  ];
}
