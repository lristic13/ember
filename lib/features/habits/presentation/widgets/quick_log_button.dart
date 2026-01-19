import 'package:ember/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';

class QuickLogButton extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  final Color? color;
  final IconData icon;

  const QuickLogButton({
    super.key,
    required this.onTap,
    this.color,
    this.icon = Icons.add,
  });

  @override
  ConsumerState<QuickLogButton> createState() => _QuickLogButtonState();
}

class _QuickLogButtonState extends ConsumerState<QuickLogButton>
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    final theme = Theme.of(context);
    final effectiveColor = widget.color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            color: AppColors.surface,
            size: AppDimensions.iconMd,
          ),
        ),
      ),
    );
  }
}
