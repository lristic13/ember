import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../viewmodels/handle_setup_view_model.dart';

/// Trailing icon for the handle field: spinner while checking, a green check
/// when available, a red ✕ when taken/invalid.
class HandleStatusIcon extends StatelessWidget {
  final HandleStatus status;

  const HandleStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case HandleStatus.checking:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: EmberPalette.of(context).dim,
          ),
        );
      case HandleStatus.available:
        return _chip(EmberSemantic.good, EmberSemantic.goodChip, Icons.check_rounded);
      case HandleStatus.taken:
      case HandleStatus.invalid:
        return _chip(
          EmberSemantic.danger,
          EmberSemantic.danger.withValues(alpha: 0.13),
          Icons.close_rounded,
        );
      case HandleStatus.idle:
        return const SizedBox.shrink();
    }
  }

  Widget _chip(Color color, Color bg, IconData icon) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    child: Icon(icon, size: 14, color: color),
  );
}
