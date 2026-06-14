import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import 'emoji_picker_sheet.dart';

class EmojiPicker extends StatelessWidget {
  final String? selectedEmoji;
  final ValueChanged<String?> onChanged;

  const EmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onChanged,
  });

  void _openSheet(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.65;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: EmojiPickerSheet(
            selectedEmoji: selectedEmoji,
            onEmojiSelected: (emoji) {
              onChanged(emoji);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasEmoji = selectedEmoji != null;

    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        alignment: Alignment.center,
        child: hasEmoji
            ? Text(selectedEmoji!, style: const TextStyle(fontSize: 28))
            : Icon(
                Icons.add_reaction_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                size: 26,
              ),
      ),
    );
  }
}
