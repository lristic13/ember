import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Branding footer for the share card.
/// Displays "Made with Ember" with the app icon.
class ShareCardBranding extends StatelessWidget {
  const ShareCardBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App icon
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/icon/logo_crni_gradient.png',
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Made with Ember',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 36,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
