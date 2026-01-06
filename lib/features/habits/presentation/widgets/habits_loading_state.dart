import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class HabitsLoadingState extends StatelessWidget {
  const HabitsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.accent,
      ),
    );
  }
}
