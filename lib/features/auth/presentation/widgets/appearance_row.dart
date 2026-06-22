import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../../../../core/theme/theme_provider.dart';

/// The Profile "Appearance" card: a labelled row plus an Auto / Light / Dark
/// segmented control wired to [ThemeNotifier].
class AppearanceRow extends ConsumerWidget {
  const AppearanceRow({super.key});

  static const _options = <(String, ThemeMode)>[
    ('Auto', ThemeMode.system),
    ('Light', ThemeMode.light),
    ('Dark', ThemeMode.dark),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final mode = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.cardHi,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: palette.border),
                ),
                child: Icon(Icons.contrast_rounded, size: 17, color: palette.text),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: EmberText.display(
                        14,
                        color: palette.text,
                        letterSpacingEm: -0.01,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Match the mood you're in",
                      style: EmberText.display(
                        10,
                        color: palette.dim,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: palette.field,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                for (final (label, value) in _options)
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(themeProvider.notifier).setMode(value),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: mode == value
                              ? EmberGradients.accent155
                              : null,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: mode == value
                              ? [
                                  BoxShadow(
                                    color: EmberAccent.glow(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          label,
                          style: EmberText.display(
                            12,
                            color: mode == value
                                ? EmberAccent.ink
                                : palette.dim,
                          ),
                        ),
                      ),
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
