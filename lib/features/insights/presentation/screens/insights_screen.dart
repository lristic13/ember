import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../../domain/entities/activity_insight.dart';
import '../../domain/entities/insights_period.dart';
import '../viewmodels/insights_state.dart';
import '../viewmodels/insights_viewmodel.dart';
import '../widgets/insights_completion_hero.dart';
import '../widgets/insights_empty_state.dart';
import '../widgets/insights_ranked_row.dart';
import '../widgets/insights_range_pill.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsViewModelProvider);
    final palette = EmberPalette.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: palette.bg.withValues(alpha: 0.7),
              title: Text(
                'Insights',
                style: EmberText.display(19, color: palette.text),
              ),
              actions: [
                if (state is InsightsLoaded)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: InsightsRangePill(
                      selectedPeriod: state.period,
                      onPeriodChanged: (p) =>
                          ref.read(insightsViewModelProvider.notifier).setPeriod(p),
                    ),
                  ),
              ],
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
              Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 16),
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
          :final allTimeTopName,
          :final allTimeTopPercent,
        ) =>
          insights.isEmpty
              ? const InsightsEmptyState()
              : _InsightsBody(
                  period: period,
                  insights: insights,
                  topName: allTimeTopName ?? insights.first.activity.name,
                  topPercent: allTimeTopPercent,
                  palette: palette,
                ),
      },
    );
  }
}

class _InsightsBody extends StatelessWidget {
  final InsightsPeriod period;
  final List<ActivityInsight> insights;
  final String topName;
  final int topPercent;
  final EmberPalette palette;

  const _InsightsBody({
    required this.period,
    required this.insights,
    required this.topName,
    required this.topPercent,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 40),
      children: [
        // Hero is all-time; the ranked list below is the selected period.
        InsightsCompletionHero(
          rangeLabel: 'ALL TIME',
          habitName: topName,
          percent: topPercent,
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            period.days == 7 ? 'RANKED THIS WEEK' : 'RANKED',
            style: EmberText.mono(12, color: palette.dim),
          ),
        ),
        for (final insight in insights)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InsightsRankedRow(insight: insight),
          ),
      ],
    );
  }
}
