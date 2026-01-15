import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/activity_insight.dart';

class InsightsBarChart extends StatelessWidget {
  final List<ActivityInsight> insights;
  final ActivityInsight? selectedInsight;
  final ValueChanged<ActivityInsight?>? onBarTap;

  const InsightsBarChart({
    super.key,
    required this.insights,
    this.selectedInsight,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback: (event, response) {
              if (event is FlTapUpEvent && response?.spot != null) {
                final index = response!.spot!.touchedBarGroupIndex;
                if (index >= 0 && index < insights.length) {
                  onBarTap?.call(insights[index]);
                }
              }
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.surface,
              tooltipPadding: const EdgeInsets.all(AppDimensions.paddingSm),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final insight = insights[groupIndex];
                return BarTooltipItem(
                  '${insight.activity.name}\n${insight.consistencyPercent.round()}%',
                  TextStyle(
                    color: insight.activity.gradient.max,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= insights.length) {
                    return const SizedBox.shrink();
                  }
                  final insight = insights[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.paddingSm),
                    child: Text(
                      insight.activity.emoji ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.surfaceLight,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            final isSelected = selectedInsight?.activity.id == insight.activity.id;
            final gradient = insight.activity.gradient;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: insight.consistencyPercent,
                  color: gradient.max,
                  width: isSelected ? 28 : 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: AppColors.surfaceLight,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }
}
