import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/emoji_categories.dart';

class EmojiPickerSheet extends StatelessWidget {
  final String? selectedEmoji;
  final ValueChanged<String?> onEmojiSelected;

  const EmojiPickerSheet({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Default',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSm),
            GestureDetector(
              onTap: () => onEmojiSelected(null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selectedEmoji == null
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(
                    color: selectedEmoji == null
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_fire_department,
                  size: 22,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            ...emojiCategories.map(
              (category) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.marginLg),
                  Text(
                    category.title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSm),
                  Wrap(
                    spacing: AppDimensions.marginSm,
                    runSpacing: AppDimensions.marginSm,
                    children: category.emojis.map((emoji) {
                      final isSelected = selectedEmoji == emoji;
                      return GestureDetector(
                        onTap: () => onEmojiSelected(emoji),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.marginMd),
          ],
        ),
      ),
    );
  }
}
