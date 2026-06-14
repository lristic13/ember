import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';

/// Sticky bottom "Add Activity" primary button — the single primary action
/// language: accent gradient fill, ink text, soft accent glow.
class AddActivityBar extends StatelessWidget {
  final VoidCallback onTap;

  const AddActivityBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [palette.bg, palette.bg.withValues(alpha: 0.0)],
          stops: const [0.6, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: EmberGradients.accent155,
                  boxShadow: [
                    BoxShadow(
                      color: EmberAccent.glow(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: EmberAccent.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Activity',
                      style: EmberText.display(
                        17,
                        color: EmberAccent.ink,
                        letterSpacingEm: -0.01,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
