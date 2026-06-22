import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Apple logo glyph (black), for the "Continue with Apple" button.
class AppleGlyph extends StatelessWidget {
  final double size;

  const AppleGlyph({super.key, this.size = 15});

  static const _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<path d="M17.05 12.04c-.03-2.9 2.37-4.3 2.48-4.36-1.35-1.98-3.46-2.25-4.21-2.28-1.79-.18-3.5 1.05-4.41 1.05-.91 0-2.31-1.03-3.8-1-1.96.03-3.77 1.14-4.78 2.9-2.04 3.54-.52 8.78 1.46 11.65.97 1.4 2.12 2.98 3.63 2.92 1.46-.06 2.01-.94 3.77-.94 1.76 0 2.26.94 3.8.91 1.57-.03 2.56-1.43 3.52-2.84 1.11-1.63 1.57-3.21 1.59-3.29-.03-.02-3.05-1.17-3.08-4.64z" fill="#000000"/>'
      '<path d="M14.13 3.93c.81-.98 1.35-2.34 1.2-3.7-1.16.05-2.57.78-3.4 1.76-.75.86-1.4 2.25-1.23 3.57 1.29.1 2.62-.66 3.43-1.63z" fill="#000000"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_svg, width: size, height: size);
}
