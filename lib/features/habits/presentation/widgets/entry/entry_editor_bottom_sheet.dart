import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../../domain/entities/tracking_type.dart';
import '../../viewmodels/habit_entries_viewmodel.dart';
import 'entry_editor_completion_content.dart';
import 'entry_editor_quantity_content.dart';

class EntryEditorBottomSheet extends ConsumerStatefulWidget {
  final String habitId;
  final String habitName;
  final TrackingType trackingType;
  final String? unit;
  final DateTime date;
  final double currentValue;

  const EntryEditorBottomSheet({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.trackingType,
    this.unit,
    required this.date,
    required this.currentValue,
  });

  @override
  ConsumerState<EntryEditorBottomSheet> createState() =>
      _EntryEditorBottomSheetState();
}

class _EntryEditorBottomSheetState
    extends ConsumerState<EntryEditorBottomSheet> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentValue > 0 ? widget.currentValue.toString() : '',
    );
    _isCompleted = widget.currentValue > 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    if (date_utils.DateUtils.isToday(date)) {
      return AppStrings.today;
    }
    if (date_utils.DateUtils.isYesterday(date)) {
      return AppStrings.yesterday;
    }
    return DateFormat.MMMEd().format(date);
  }

  Future<void> _saveQuantity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final value = double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0;
    final viewModel = ref.read(
      habitEntriesViewModelProvider(widget.habitId).notifier,
    );
    final success = await viewModel.logEntry(widget.date, value);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        _showSaveError();
      }
    }
  }

  Future<void> _saveCompletion(bool completed) async {
    setState(() => _isSaving = true);

    final value = completed ? 1.0 : 0.0;
    final viewModel = ref.read(
      habitEntriesViewModelProvider(widget.habitId).notifier,
    );
    final success = await viewModel.logEntry(widget.date, value);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        _showSaveError();
      }
    }
  }

  void _showSaveError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Couldn't save — please try again.")),
    );
  }

  Future<void> _clear() async {
    setState(() => _isSaving = true);

    final viewModel = ref.read(
      habitEntriesViewModelProvider(widget.habitId).notifier,
    );
    final success = await viewModel.logEntry(widget.date, 0);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        _showSaveError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingLg,
        right: AppDimensions.paddingLg,
        top: AppDimensions.paddingLg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(widget.habitName, style: AppTextStyles.headlineMedium.copyWith(
            color: theme.colorScheme.onSurface,
          )),
          const SizedBox(height: AppDimensions.paddingXs),
          Text(
            _formatDate(widget.date),
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLg),

          // Content based on tracking type
          if (widget.trackingType == TrackingType.completion)
            EntryEditorCompletionContent(
              isCompleted: _isCompleted,
              isSaving: _isSaving,
              onSave: _saveCompletion,
            )
          else
            EntryEditorQuantityContent(
              formKey: _formKey,
              controller: _controller,
              unit: widget.unit,
              isSaving: _isSaving,
              onClear: _clear,
              onSave: _saveQuantity,
            ),
        ],
      ),
    );
  }
}

/// Shows the entry editor bottom sheet and returns true if an entry was saved.
Future<bool?> showEntryEditorBottomSheet({
  required BuildContext context,
  required String habitId,
  required String habitName,
  required TrackingType trackingType,
  String? unit,
  required DateTime date,
  required double currentValue,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.bottomSheetRadius),
      ),
    ),
    builder: (context) => EntryEditorBottomSheet(
      habitId: habitId,
      habitName: habitName,
      trackingType: trackingType,
      unit: unit,
      date: date,
      currentValue: currentValue,
    ),
  );
}
