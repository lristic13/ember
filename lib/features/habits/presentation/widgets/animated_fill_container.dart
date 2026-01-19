import 'package:flutter/material.dart';

/// A container that animates a fill effect from bottom to top based on intensity.
///
/// Used for heatmap cells to provide visual feedback when logging entries.
class AnimatedFillContainer extends StatefulWidget {
  /// The current intensity value (0.0 to 1.0) that determines fill height.
  final double intensity;

  /// The color of the filled portion.
  final Color fillColor;

  /// The background color (unfilled portion).
  final Color backgroundColor;

  /// Border radius for the container.
  final BorderRadius borderRadius;

  /// Duration of the fill animation.
  final Duration duration;

  /// Optional glow color for high intensity cells.
  final Color? glowColor;

  /// Whether to show the glow effect (typically when intensity >= 0.9).
  final bool showGlow;

  /// Optional child widget to display on top of the fill (e.g., day number).
  final Widget? child;

  /// Size of the container.
  final double? width;
  final double? height;

  /// Optional border to display around the container.
  final Border? border;

  const AnimatedFillContainer({
    super.key,
    required this.intensity,
    required this.fillColor,
    required this.backgroundColor,
    this.borderRadius = BorderRadius.zero,
    this.duration = const Duration(milliseconds: 350),
    this.glowColor,
    this.showGlow = false,
    this.child,
    this.width,
    this.height,
    this.border,
  });

  @override
  State<AnimatedFillContainer> createState() => _AnimatedFillContainerState();
}

class _AnimatedFillContainerState extends State<AnimatedFillContainer>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _glowController;
  late Animation<double> _fillAnimation;

  bool _wasShowingGlow = false;

  @override
  void initState() {
    super.initState();
    _wasShowingGlow = widget.showGlow;

    _fillController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );

    // Initialize animations at current values (no animation on first build)
    _fillAnimation = AlwaysStoppedAnimation(widget.intensity);

    // Set glow controller to match initial state
    if (widget.showGlow) {
      _glowController.value = 1.0;
    }

    // Listen for fill animation completion to trigger glow
    _fillController.addStatusListener(_onFillAnimationStatus);
  }

  @override
  void dispose() {
    _fillController.removeStatusListener(_onFillAnimationStatus);
    _fillController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onFillAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // After fill completes, animate glow if needed
      if (widget.showGlow && !_wasShowingGlow) {
        _glowController.forward();
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedFillContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final intensityChanged = widget.intensity != oldWidget.intensity;
    final glowChanged = widget.showGlow != oldWidget.showGlow;

    if (intensityChanged) {
      _animateToNewIntensity(oldWidget.intensity);
    }

    if (glowChanged && !intensityChanged) {
      // Glow changed without intensity change (e.g., theme switch)
      _animateGlow();
    }

    _wasShowingGlow = oldWidget.showGlow;
  }

  void _animateToNewIntensity(double fromIntensity) {
    final wasEmpty = fromIntensity <= 0;
    final isEmpty = widget.intensity <= 0;

    // Handle rapid input: if animation is running, jump to current target
    double startFill;
    if (_fillController.isAnimating) {
      _fillController.stop();
      // Start from where we visually are
      startFill = _fillAnimation.value;
    } else {
      startFill = wasEmpty ? 0.0 : 1.0;
    }

    // If glow should disappear, start fading it immediately
    if (_wasShowingGlow && !widget.showGlow) {
      _glowController.reverse();
    }

    // Animate fill height: 0→1 when filling, 1→0 when emptying
    final endFill = isEmpty ? 0.0 : 1.0;

    // Only animate if there's a change in fill state
    if (startFill != endFill) {
      _fillAnimation = Tween<double>(
        begin: startFill,
        end: endFill,
      ).animate(CurvedAnimation(
        parent: _fillController,
        curve: Curves.easeOut,
      ));

      _fillController.forward(from: 0.0);
    }
  }

  void _animateGlow() {
    if (widget.showGlow) {
      _glowController.forward();
    } else {
      _glowController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fillController, _glowController]),
      builder: (context, child) {
        // Fill animation value (0 to 1) - animates the height
        final fillProgress = _fillController.isAnimating || _fillController.isCompleted
            ? _fillAnimation.value
            : (widget.intensity > 0 ? 1.0 : 0.0);

        final glowOpacity = _glowController.value;

        // Calculate inner radius accounting for border width
        final borderWidth = widget.border?.top.width ?? 0;
        final innerRadius = widget.borderRadius.subtract(
          BorderRadius.all(Radius.circular(borderWidth)),
        );

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
            border: widget.border,
            boxShadow: widget.glowColor != null && glowOpacity > 0
                ? [
                    BoxShadow(
                      color: widget.glowColor!.withValues(alpha: 0.6 * glowOpacity),
                      blurRadius: 6 * glowOpacity,
                      spreadRadius: 1 * glowOpacity,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: innerRadius,
            child: Stack(
              children: [
                // Animated fill from bottom - always fills to 100%, color varies by intensity
                if (fillProgress > 0)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: fillProgress.clamp(0.0, 1.0),
                      widthFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.fillColor,
                        ),
                      ),
                    ),
                  ),
                // Child (e.g., day number) on top
                if (widget.child != null)
                  Positioned.fill(
                    child: Center(child: widget.child),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
