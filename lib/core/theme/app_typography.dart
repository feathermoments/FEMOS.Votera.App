import 'package:flutter/material.dart';
import 'package:votera_app/core/theme/app_colors.dart';

/// Typography scale from UI Implementation Guide §3.
/// Fonts: Manrope (display & body), JetBrains Mono (data/numbers).
abstract final class AppTypography {
  static const _manrope = 'Manrope';
  static const _mono = 'JetBrainsMono';

  // ── Screen Title (22px, w800, -0.5 tracking) ─────
  static const screenTitle = TextStyle(
    fontFamily: _manrope,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  // ── Section Heading (15–16px, w700) ───────────────
  static const sectionHeading = TextStyle(
    fontFamily: _manrope,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  // ── Card Title (14px, w600) ───────────────────────
  static const cardTitle = TextStyle(
    fontFamily: _manrope,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ── Body (13–14px, w500) ──────────────────────────
  static const body = TextStyle(
    fontFamily: _manrope,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const bodySmall = TextStyle(
    fontFamily: _manrope,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // ── Caption / Meta (11–12px, w500) ────────────────
  static const caption = TextStyle(
    fontFamily: _manrope,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const captionSmall = TextStyle(
    fontFamily: _manrope,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  // ── Label / Tag (9–11px, w700–800, uppercase) ─────
  static const label = TextStyle(
    fontFamily: _manrope,
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
  );

  static const labelSmall = TextStyle(
    fontFamily: _manrope,
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: AppColors.textMuted,
  );

  // ── Score Number (28–30px, w800, mono) ────────────
  static const scoreNumber = TextStyle(
    fontFamily: _mono,
    fontSize: 28,
    fontWeight: FontWeight.w800,
  );

  // ── Status Bar Time (12px, w600, mono) ────────────
  static const statusBarTime = TextStyle(
    fontFamily: _mono,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // ── Login Welcome (32px, w800) ────────────────────
  static const loginWelcome = TextStyle(
    fontFamily: _manrope,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  // ── Brand Name (34px, w800) ───────────────────────
  static const brandName = TextStyle(
    fontFamily: _manrope,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  // ── Brand Name Small (21px, w800) ─────────────────
  static const brandNameSmall = TextStyle(
    fontFamily: _manrope,
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // ── Input Text (14px, w500) ───────────────────────
  static const input = TextStyle(
    fontFamily: _manrope,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ── Input Label (11px, w700, uppercase) ───────────
  static const inputLabel = TextStyle(
    fontFamily: _manrope,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: AppColors.textSecondary,
  );

  // ── Button (15–16px, w700) ────────────────────────
  static const button = TextStyle(
    fontFamily: _manrope,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // ── Drawer Section Header (9px, w800, uppercase) ──
  static const drawerSection = labelSmall;

  // ── Greeting (12px, w500) ─────────────────────────
  static const greeting = TextStyle(
    fontFamily: _manrope,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ── Greeting Name (19px, w800) ────────────────────
  static const greetingName = TextStyle(
    fontFamily: _manrope,
    fontSize: 19,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // ── Tab Label (10px, w500/700) ────────────────────
  static const tabLabel = TextStyle(
    fontFamily: _manrope,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const tabLabelActive = TextStyle(
    fontFamily: _manrope,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.blue,
  );
}
