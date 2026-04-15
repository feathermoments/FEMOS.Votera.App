import 'package:flutter/material.dart';

/// All color tokens from UI Implementation Guide §2.
/// Source of truth: Arogya Track app prototype.
abstract final class AppColors {
  // ── Primary — Deep Maroon ─────────────────────────
  static const blue = Color.fromARGB(255, 30, 40, 156);
  static const blueLight = Color.fromARGB(255, 97, 114, 241);
  static const blueDark = Color.fromARGB(255, 11, 7, 135);
  static const blueSoft = Color(0xFFFDE8EC);

  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, blueLight],
  );

  static const blueDeepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, blueLight, Color(0xFFD4264D)],
  );

  // ── Whites & Surfaces ─────────────────────────────
  static const whitePrimary = Color(0xFFFEFEFE);
  static const whiteSurface = Color(0xFFFAFBFC);
  static const whiteCard = Color(0xFFFFFFFF);
  static const whiteInput = Color(0xFFF9FAFB);

  // ── Metallic ──────────────────────────────────────
  static const metallicLight = Color(0xFFF3F4F6);
  static const metallicBorder = Color(0xFFE5E7EB);

  // ── Text ──────────────────────────────────────────
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF4B5563);
  static const textMuted = Color(0xFF9CA3AF);
  static const textFaint = Color(0xFFD1D5DB);

  // ── Warnings ──────────────────────────────────────
  static const success = Color(0xFF22C55E);
  static const successDark = Color(0xFF15803D);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF2C7BE5);

  // ── Gold ──────────────────────────────────────────
  static const gold = Color(0xFFD4A843);
  static const goldLight = Color(0xFFFEF3C7);

  // ── Dark Theme (Notch, Status Bar) ────────────────
  static const notchBg = Color(0xFF1A1A2E);
}
