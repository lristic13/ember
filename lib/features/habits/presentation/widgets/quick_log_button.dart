import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class QuickLogButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;

  const QuickLogButton({
    super.key,
    required this.onTap,
    this.color = AppColors.accent,
  });

  @override
  State<QuickLogButton> createState() => _QuickLogButtonState();
}

class _QuickLogButtonState extends State<QuickLogButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.add,
            color: AppColors.background,
            size: AppDimensions.iconMd,
          ),
        ),
      ),
    );
  }
}
