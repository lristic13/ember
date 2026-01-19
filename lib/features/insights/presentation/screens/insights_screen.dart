import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../viewmodels/insights_state.dart';
import '../viewmodels/insights_viewmodel.dart';
import '../widgets/activity_consistency_item.dart';
import '../widgets/insights_empty_state.dart';
import '../widgets/insights_bar_chart.dart';
import '../widgets/insights_tip_card.dart';
import '../widgets/period_selector.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
              title: const Text(
                AppStrings.insights,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: switch (state) {
        InsightsLoading() => const Center(child: CircularProgressIndicator()),
        InsightsError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: AppDimensions.paddingMd),
              ElevatedButton(
                onPressed: () =>
                    ref.read(insightsViewModelProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        InsightsLoaded(
          :final period,
          :final insights,
          :final selectedInsight,
        ) =>
          insights.isEmpty
              ? const InsightsEmptyState()
              : SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top:
                        MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        AppDimensions.paddingMd,
                    left: AppDimensions.paddingMd,
                    right: AppDimensions.paddingMd,
                    bottom: AppDimensions.paddingMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PeriodSelector(
                            selectedPeriod: period,
                            onPeriodChanged: (newPeriod) {
                              ref
                                  .read(insightsViewModelProvider.notifier)
                                  .setPeriod(newPeriod);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingLg),

                      // Bar chart
                      InsightsBarChart(
                        insights: insights,
                        selectedInsight: selectedInsight,
                        onBarTap: (insight) {
                          ref
                              .read(insightsViewModelProvider.notifier)
                              .selectInsight(insight);
                        },
                      ), // Tip card
                      InsightsTipCard(insights: insights),
                      const SizedBox(height: AppDimensions.paddingMd),

                      // Divider
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: AppDimensions.paddingMd),

                      // Activity list
                      ...insights.map((insight) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSm,
                          ),
                          child: ActivityConsistencyItem(
                            insight: insight,
                            isHighlighted:
                                selectedInsight?.activity.id ==
                                insight.activity.id,
                            onTap: () {
                              ref
                                  .read(insightsViewModelProvider.notifier)
                                  .selectInsight(insight);
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: AppDimensions.paddingMd),
                    ],
                  ),
                ),
      },
    );
  }
}
