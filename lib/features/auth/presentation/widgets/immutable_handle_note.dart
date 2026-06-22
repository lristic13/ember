import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';

/// The ember-tinted "Handles are permanent" note on the handle-setup screen.
class ImmutableHandleNote extends StatelessWidget {
  const ImmutableHandleNote({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EmberAccent.neon.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: EmberAccent.neon.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: EmberAccent.bright,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Handles are permanent. ',
                style: EmberText.display(
                  12,
                  color: EmberAccent.bright,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: "You can't change this later.",
                    style: EmberText.display(
                      12,
                      color: palette.dim,
                      weight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
