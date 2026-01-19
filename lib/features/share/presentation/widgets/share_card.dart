import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/habit_gradient_presets.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import 'share_card_heat_map_full.dart';
import 'share_card_heat_map_month.dart';
import 'share_card_stats.dart';

/// Main share card widget for generating shareable images.
/// Fixed dimensions optimized for Instagram/Facebook stories (9:16 aspect ratio).
class ShareCard extends StatelessWidget {
  final Habit habit;
  final List<HabitEntry> entries;
  final int year;
  final int? month;

  /// Fixed dimensions for social sharing (Story format)
  static const double width = 1080;
  static const double height = 1920;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  const ShareCard({
    super.key,
    required this.habit,
    required this.entries,
    required this.year,
    this.month,
  });

  bool get isMonthly => month != null;

  @override
  Widget build(BuildContext context) {
    final gradient = HabitGradientPresets.getById(habit.gradientId);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradient.max.withValues(alpha: 0.3),
            gradient.high.withValues(alpha: 0.2),
            gradient.medium.withValues(alpha: 0.15),
            gradient.low.withValues(alpha: 0.2),
            gradient.max.withValues(alpha: 0.25),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative glow circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    gradient.max.withValues(alpha: 0.2),
                    gradient.max.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    gradient.medium.withValues(alpha: 0.15),
                    gradient.medium.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Activity header
                _buildHeader(gradient),

                const SizedBox(height: 48),

                // Heat map - takes most of the space
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: gradient.max.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: isMonthly
                        ? ShareCardHeatMapMonth(
                            entries: entries,
                            year: year,
                            month: month!,
                            gradient: gradient,
                          )
                        : ShareCardHeatMapFull(
                            entries: entries,
                            year: year,
                            gradient: gradient,
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // Stats
                ShareCardStats(
                  habit: habit,
                  entries: entries,
                  year: year,
                  month: month,
                  gradient: gradient,
                ),

                const SizedBox(height: 40),

                // Call to action banner
                // _buildBanner(gradient),

                // Branding
                // const ShareCardBranding(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(gradient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [gradient.max, gradient.high]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.max.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Start your streak today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your habits with Ember',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(gradient) {
    return Row(
      children: [
        if (habit.emoji != null) ...[
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: gradient.max.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: gradient.max.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(habit.emoji!, style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(width: 24),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'I tracked my ${habit.name} journey in ${isMonthly ? _monthNames[month! - 1] : year} using ember. \u{1F525}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: gradient.max.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isMonthly
                      ? '${_monthNames[month! - 1]} $year'
                      : '$year Year in Review',
                  style: TextStyle(
                    color: gradient.max,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
