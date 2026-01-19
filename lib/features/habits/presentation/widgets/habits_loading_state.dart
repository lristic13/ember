import 'package:flutter/material.dart';

class HabitsLoadingState extends StatelessWidget {
  const HabitsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
