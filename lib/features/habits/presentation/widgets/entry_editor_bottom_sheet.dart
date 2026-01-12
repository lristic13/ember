import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;
import '../../domain/entities/tracking_type.dart';
import '../viewmodels/habit_entries_viewmodel.dart';

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

    final value = double.tryParse(_controller.text) ?? 0;
    final viewModel = ref.read(
      habitEntriesViewModelProvider(widget.habitId).notifier,
    );
    final success = await viewModel.logEntry(widget.date, value);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop(true);
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
      }
    }
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Text(widget.habitName, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppDimensions.paddingXs),
          Text(
            _formatDate(widget.date),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLg),

          // Content based on tracking type
          if (widget.trackingType == TrackingType.completion)
            _buildCompletionUI()
          else
            _buildQuantityUI(),
        ],
      ),
    );
  }

  Widget _buildCompletionUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toggle buttons
        Row(
          children: [
            Expanded(
              child: _CompletionButton(
                label: AppStrings.markAsDone,
                icon: Icons.check_circle_outline,
                isSelected: _isCompleted,
                isLoading: _isSaving && _isCompleted,
                onTap: _isSaving ? null : () => _saveCompletion(true),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMd),
            Expanded(
              child: _CompletionButton(
                label: AppStrings.markAsNotDone,
                icon: Icons.cancel_outlined,
                isSelected: !_isCompleted,
                isLoading: _isSaving && !_isCompleted,
                onTap: _isSaving ? null : () => _saveCompletion(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityUI() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Value input
          TextFormField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: widget.unit != null
                  ? '${AppStrings.entryValue} (${widget.unit})'
                  : AppStrings.entryValue,
              hintText: '0',
            ),
            autofocus: true,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final parsed = double.tryParse(value);
                if (parsed == null || parsed < 0) {
                  return AppStrings.validationNonNegative;
                }
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.paddingLg),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _clear,
                  child: const Text(AppStrings.clear),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveQuantity,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  const _CompletionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingLg,
          horizontal: AppDimensions.paddingMd,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            const SizedBox(height: AppDimensions.paddingSm),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
    backgroundColor: AppColors.surface,
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
