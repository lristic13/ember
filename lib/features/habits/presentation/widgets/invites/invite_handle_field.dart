import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/ember_tokens.dart';

/// The `@handle` input row for the invite sheet — dim `@` prefix, mono value
/// with a neon caret, lowercased as typed.
class InviteHandleField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const InviteHandleField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border, width: 2),
      ),
      child: Row(
        children: [
          Text('@', style: EmberText.mono(20, color: palette.dimmer)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              cursorColor: EmberAccent.neon,
              cursorWidth: 2,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.send,
              onSubmitted: onSubmitted,
              style: EmberText.mono(20, color: palette.text),
              inputFormatters: [
                TextInputFormatter.withFunction(
                  (oldValue, newValue) =>
                      newValue.copyWith(text: newValue.text.toLowerCase()),
                ),
              ],
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'handle',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
