import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_assets.dart';

class FlameAnimation extends StatelessWidget {
  final double size;

  const FlameAnimation({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return DotLottieLoader.fromAsset(
      AppAssets.flameAnimation,
      frameBuilder: (context, dotLottie) {
        if (dotLottie == null) {
          return const SizedBox.shrink();
        }
        return Lottie.memory(
          dotLottie.animations.values.first,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
