import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../viewmodels/handle_setup_view_model.dart';
import 'handle_status_icon.dart';

/// The `@handle` input: a `field`-filled row with a state-coloured 2px border,
/// the dim `@` prefix, a mono value with a neon caret, and a trailing status
/// icon. Lowercases input as it's typed.
class HandleField extends StatelessWidget {
  final TextEditingController controller;
  final HandleStatus status;
  final ValueChanged<String> onChanged;

  const HandleField({
    super.key,
    required this.controller,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);

    final Color borderColor;
    switch (status) {
      case HandleStatus.available:
        borderColor = EmberSemantic.good.withValues(alpha: 0.6);
      case HandleStatus.taken:
      case HandleStatus.invalid:
        borderColor = EmberSemantic.line;
      case HandleStatus.checking:
      case HandleStatus.idle:
        borderColor = palette.border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: status == HandleStatus.available
            ? [BoxShadow(color: EmberSemantic.goodGlow(0.13), blurRadius: 14)]
            : null,
      ),
      child: Row(
        children: [
          Text('@', style: EmberText.mono(20, color: palette.dimmer)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              cursorColor: EmberAccent.neon,
              cursorWidth: 2,
              autocorrect: false,
              enableSuggestions: false,
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
                hintText: '',
              ),
            ),
          ),
          const SizedBox(width: 8),
          HandleStatusIcon(status: status),
        ],
      ),
    );
  }
}
