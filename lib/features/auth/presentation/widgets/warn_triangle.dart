import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/ember_tokens.dart';

/// A warning triangle (danger-coloured), used in error cards and the
/// delete-account confirmation.
class WarnTriangle extends StatelessWidget {
  final double size;
  final Color? color;

  const WarnTriangle({super.key, this.size = 15, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? EmberSemantic.danger;
    final hex =
        '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">'
        '<path d="M12 3.2 22 20H2L12 3.2Z" stroke="$hex" stroke-width="2" stroke-linejoin="round"/>'
        '<path d="M12 10v4.4" stroke="$hex" stroke-width="2.2" stroke-linecap="round"/>'
        '<circle cx="12" cy="17.4" r="1.2" fill="$hex"/>'
        '</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}
