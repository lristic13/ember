import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../../../../shared/widgets/ember_wordmark.dart';

/// Shown while persisted auth state is resolving, so the gated home screen
/// never flashes before the login wall.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    return Scaffold(
      backgroundColor: palette.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmberWordmark(size: 28),
            const SizedBox(height: 24),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: palette.dim),
            ),
          ],
        ),
      ),
    );
  }
}
