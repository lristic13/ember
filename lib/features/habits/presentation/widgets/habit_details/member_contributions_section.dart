import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/shared_habit_providers.dart';

/// For an "Everyone" habit: where each member stands **today** — checked in or
/// not (completion), or the amount they logged (quantity).
class MemberContributionsSection extends ConsumerWidget {
  final Habit habit;

  const MemberContributionsSection({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final color = HabitColor.fromGradient(habit.gradient);

    final checks =
        ref.watch(sharedHabitChecksProvider(habit.id)).asData?.value ??
        const <DateTime, Map<String, double>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayAmounts = checks[today] ?? const <String, double>{};

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('TODAY', style: EmberText.mono(11, color: palette.dim)),
          const SizedBox(height: 4),
          for (final p in habit.participants)
            _MemberTodayRow(
              initials: p.initials,
              name: _name(p.displayName, p.handle),
              amount: todayAmounts[p.uid] ?? 0,
              amountLabel: habit.isQuantity ? _formatQty : null,
              color: color,
            ),
        ],
      ),
    );
  }

  String _name(String? displayName, String? handle) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    return handle != null ? '@$handle' : 'Member';
  }

  String _formatQty(double amount) {
    final formatted = NumberFormat('#,##0.##').format(amount);
    final unit = habit.unit;
    return (unit == null || unit.isEmpty) ? formatted : '$formatted $unit';
  }
}

class _MemberTodayRow extends StatelessWidget {
  final String initials;
  final String name;
  final double amount;

  /// Non-null for quantity habits — formats the amount; null = completion.
  final String Function(double)? amountLabel;
  final HabitColor color;

  const _MemberTodayRow({
    required this.initials,
    required this.name,
    required this.amount,
    required this.amountLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final done = amount > 0;

    final Widget trailing;
    if (amountLabel != null) {
      trailing = Text(
        done ? amountLabel!(amount) : '—',
        style: EmberText.mono(13, color: done ? color.base : palette.dimmer),
      );
    } else {
      trailing = Icon(
        done ? Icons.check_circle_rounded : Icons.circle_outlined,
        size: 20,
        color: done ? color.base : palette.dimmer,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: EmberGradients.accent155,
            ),
            child: Text(
              initials,
              style: EmberText.display(12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: EmberText.display(15, color: palette.text),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
