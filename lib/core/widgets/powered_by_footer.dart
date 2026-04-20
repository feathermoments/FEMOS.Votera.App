import 'package:flutter/material.dart';
import 'package:votera_app/core/theme/app_colors.dart';

/// Displays a "Powered by FeatherMoments" attribution footer.
///
/// Pass [onDarkBackground] = true when rendering over a dark/gradient surface
/// (e.g. splash screen) so the text uses white tones.  Leave it false (the
/// default) for light or adaptive surfaces like the login form or settings.
class PoweredByFooter extends StatelessWidget {
  const PoweredByFooter({super.key, this.onDarkBackground = false});

  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final labelColor = onDarkBackground ? Colors.white38 : AppColors.textFaint;
    final brandColor = onDarkBackground ? Colors.white60 : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Powered by ',
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            'FeatherMoments',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: brandColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
