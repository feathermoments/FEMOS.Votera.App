import 'package:flutter/material.dart';

// ── Breakpoints ────────────────────────────────────────────────────────────────
//  Mobile   : < 600 px
//  Tablet   : 600 – 1023 px
//  Desktop  : ≥ 1024 px
// ──────────────────────────────────────────────────────────────────────────────

const double kMobileBreakpoint = 600;
const double kDesktopBreakpoint = 1024;

/// Max width for form/auth content (login, OTP, etc.)
const double kFormMaxWidth = 480.0;

/// Max width for single-column content pages (detail, settings, profile, …)
const double kContentMaxWidth = 760.0;

/// Max width for wide content pages (dashboard, lists)
const double kWideMaxWidth = 1100.0;

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => screenWidth < kMobileBreakpoint;
  bool get isTablet =>
      screenWidth >= kMobileBreakpoint && screenWidth < kDesktopBreakpoint;
  bool get isDesktop => screenWidth >= kDesktopBreakpoint;

  /// True on tablet AND desktop (anything wider than mobile).
  bool get isWide => screenWidth >= kMobileBreakpoint;
}

// ── Widgets ────────────────────────────────────────────────────────────────────

/// Centers [child] and clamps its width to [maxWidth].
/// Perfect for forms, detail pages and any single-column content.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = kContentMaxWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Builds a responsive grid:
/// - mobile  → [mobileCrossAxisCount] columns
/// - tablet  → [tabletCrossAxisCount] columns
/// - desktop → [desktopCrossAxisCount] columns
class ResponsiveGridView extends StatelessWidget {
  const ResponsiveGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.mobileCrossAxisCount = 1,
    this.tabletCrossAxisCount = 2,
    this.desktopCrossAxisCount = 3,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 12.0,
    this.crossAxisSpacing = 12.0,
    this.padding,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final int columns = context.isDesktop
        ? desktopCrossAxisCount
        : context.isTablet
        ? tabletCrossAxisCount
        : mobileCrossAxisCount;

    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
