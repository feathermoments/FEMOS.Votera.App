import 'package:flutter/material.dart';
import 'package:votera_app/core/theme/app_colors.dart';

/// A reusable gradient AppBar that implements the app-wide design system.
///
/// Renders a blue gradient background with white icons and title text.
/// Supports optional [actions], custom [leading], [bottom] (e.g. TabBar),
/// and a fully custom [titleWidget] for cases that need a multi-line title.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
  }) : assert(
         title != null || titleWidget != null,
         'Provide either title or titleWidget',
       );

  /// Plain-text title. Ignored when [titleWidget] is supplied.
  final String? title;

  /// Custom title widget (e.g. a Column with name + subtitle).
  /// Takes precedence over [title].
  final Widget? titleWidget;

  /// Action buttons shown on the trailing side.
  final List<Widget>? actions;

  /// Custom leading widget. When null, Flutter shows the back button
  /// automatically (controlled by [automaticallyImplyLeading]).
  final Widget? leading;

  /// Whether Flutter should auto-insert a leading back button.
  /// Defaults to `true`.
  final bool automaticallyImplyLeading;

  /// Widget placed below the toolbar (e.g. a [TabBar]).
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.blueGradient),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title:
          titleWidget ??
          Text(
            title!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
      actions: actions,
      bottom: bottom,
    );
  }
}
