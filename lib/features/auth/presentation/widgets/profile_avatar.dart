import 'package:flutter/material.dart';

import '../../../../core/theme/ember_tokens.dart';

/// Circular ember-gradient avatar with the user's initials and a radial glow.
class ProfileAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const ProfileAvatar({super.key, required this.initials, this.size = 74});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.45,
      height: size * 1.45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [EmberAccent.glow(0.27), const Color(0x00000000)],
                stops: const [0.0, 0.70],
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: EmberGradients.accent155,
              boxShadow: [
                BoxShadow(
                  color: EmberAccent.glow(0.27),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              initials,
              style: EmberText.display(
                size * 0.4,
                color: Colors.white,
                letterSpacingEm: -0.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
