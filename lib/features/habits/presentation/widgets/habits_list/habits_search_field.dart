import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../viewmodels/search_query_provider.dart';

/// Compact search field that filters the habits list by name/emoji as you type.
class HabitsSearchField extends ConsumerStatefulWidget {
  const HabitsSearchField({super.key});

  @override
  ConsumerState<HabitsSearchField> createState() => _HabitsSearchFieldState();
}

class _HabitsSearchFieldState extends ConsumerState<HabitsSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(habitsSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(habitsSearchQueryProvider.notifier).setQuery(value);
    setState(() {}); // toggle the clear button
  }

  void _clear() {
    _controller.clear();
    ref.read(habitsSearchQueryProvider.notifier).clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final hasText = _controller.text.isNotEmpty;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: palette.field,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: palette.dim),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              cursorColor: EmberAccent.neon,
              cursorWidth: 2,
              style: EmberText.display(14, color: palette.text),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false, // the field's own color comes from the container
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Search habits',
                hintStyle: EmberText.display(14, color: palette.dimmer),
              ),
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: _clear,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(Icons.close_rounded, size: 16, color: palette.dim),
              ),
            ),
        ],
      ),
    );
  }
}
