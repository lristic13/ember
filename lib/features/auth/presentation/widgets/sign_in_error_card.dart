import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';
import 'warn_triangle.dart';

/// Error card shown above the sign-in buttons on auth failure.
class SignInErrorCard extends StatelessWidget {
  final String? message;

  const SignInErrorCard({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EmberSemantic.tint,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: EmberSemantic.line),
      ),
      child: Row(
        children: [
          const WarnTriangle(size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign-in failed',
                  style: EmberText.display(13, color: EmberSemantic.dangerSoft),
                ),
                const SizedBox(height: 2),
                Text(
                  message ?? 'Something went wrong. Please try again.',
                  style: EmberText.display(
                    11,
                    color: palette.dim,
                    weight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
