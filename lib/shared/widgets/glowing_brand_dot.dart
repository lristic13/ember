import 'package:flutter/material.dart';

import '../../core/theme/ember_tokens.dart';

/// The brand ember orb that gently floats up and down while its glow pulses
/// brighter and softer — used as a living accent on empty states.
class GlowingBrandDot extends StatefulWidget {
  final double size;

  const GlowingBrandDot({super.key, this.size = 34});

  @override
  State<GlowingBrandDot> createState() => _GlowingBrandDotState();
}

class _GlowingBrandDotState extends State<GlowingBrandDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final t = _t.value;
        return Transform.translate(
          offset: Offset(0, -size * 0.11 * t), // float up to ~11% of size
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [EmberAccent.bright, EmberAccent.deep],
              ),
              boxShadow: [
                BoxShadow(
                  color: EmberAccent.glow(0.35 + 0.4 * t), // brighter at apex
                  blurRadius:
                      size * (0.4 + 0.4 * t), // softer/wider as it pulses
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
