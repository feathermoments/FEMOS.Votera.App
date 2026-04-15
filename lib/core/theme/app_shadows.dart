import 'package:flutter/material.dart';
// app_shadows.dart does not require app_colors import

/// Shadow system from UI Implementation Guide §4.
abstract final class AppShadows {
  // ── Card (§4.1) ──────────────────────────────────
  static const card = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 4,
      color: Color(0x08000000),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Color(0x05000000),
    ),
  ];

  // Single default card shadow (convenience for simple uses)
  static const cardDefault = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 4,
    color: Color(0x08000000),
  );

  // ── Button (§4.2) ────────────────────────────────
  static const button = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 20,
      color: Color(0x338B1730),
    ),
  ];

  static const buttonPressed = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 10,
      color: Color(0x268B1730),
    ),
  ];

  // ── Logo (splash, login) ─────────────────────────
  static const logo = [
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 20,
      color: Color(0x338B1730),
    ),
  ];

  static const logoLarge = [
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 60,
      color: Color(0x408B1730),
    ),
    BoxShadow(
      spreadRadius: 8,
      color: Color(0x0F8B1730),
    ),
  ];

  // ── Toast (§4.9) ─────────────────────────────────
  static const toast = [
    BoxShadow(
      offset: Offset(0, 16),
      blurRadius: 48,
      color: Color(0x1F000000),
    ),
  ];

  // ── Drawer (§4.8) ────────────────────────────────
  static const drawer = [
    BoxShadow(
      offset: Offset(8, 0),
      blurRadius: 40,
      color: Color(0x14000000),
    ),
  ];

  // ── Bottom Sheet (§4.10) ─────────────────────────
  static const bottomSheet = [
    BoxShadow(
      offset: Offset(0, -8),
      blurRadius: 40,
      color: Color(0x14000000),
    ),
  ];

  // ── Phone Frame ──────────────────────────────────
  static const phoneFrame = [
    BoxShadow(spreadRadius: 2, color: Color(0xFFD0D2D8)),
    BoxShadow(spreadRadius: 6, color: Color(0xFFC0C2C8)),
    BoxShadow(spreadRadius: 8, color: Color(0xFFD0D2D8)),
    BoxShadow(
      offset: Offset(0, 40),
      blurRadius: 100,
      color: Color(0x33000000),
    ),
  ];

  // ── Avatar selected ──────────────────────────────
  static List<BoxShadow> avatarSelected(Color color) => [
        BoxShadow(
          offset: const Offset(0, 4),
          blurRadius: 14,
          color: color.withValues(alpha: 0.19),
        ),
      ];

  // ── Drawer avatar ────────────────────────────────
  static const drawerAvatar = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color(0x338B1730),
    ),
  ];

  // ── Tab dot glow ─────────────────────────────────
  static const tabDot = [
    BoxShadow(
      blurRadius: 8,
      color: Color(0x608B1730),
    ),
  ];

  // ── Social button ────────────────────────────────
  static const socialButton = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color(0x08000000),
    ),
  ];
}
