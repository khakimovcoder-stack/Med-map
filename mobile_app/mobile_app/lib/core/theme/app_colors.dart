import 'package:flutter/material.dart';

/// Color tokens — must match docs/STYLE_GUIDE.md exactly.
/// Davlat portali (e-Gov) uslubi: oq + ko'k.
class AppColors {
  AppColors._();

  // Brand blues
  static const Color bluePrimary = Color(0xFF1E40AF); // blue-800
  static const Color blueSecondary = Color(0xFF3B82F6); // blue-500
  static const Color blueLight = Color(0xFFDBEAFE); // blue-100
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color bluePrimaryDark = Color(0xFF1E3A8A); // hover

  // Semantic
  static const Color greenSuccess = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFD1FAE5);
  static const Color redDanger = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEE2E2);
  static const Color yellowWarning = Color(0xFFF59E0B);
  static const Color yellowLight = Color(0xFFFEF3C7);

  // Neutral
  static const Color grayUnknown = Color(0xFF9CA3AF); // gray-400
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray900 = Color(0xFF111827);

  // Surfaces
  static const Color background = gray50;
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray500;

  // Status colors keyed by BedStatus enum value
  static Color statusBg(String status) {
    switch (status) {
      case 'BAND':
        return redDanger;
      case 'BOSH':
        return greenSuccess;
      default:
        return grayUnknown;
    }
  }

  static Color statusBgLight(String status) {
    switch (status) {
      case 'BAND':
        return redLight;
      case 'BOSH':
        return greenLight;
      default:
        return gray100;
    }
  }
}
