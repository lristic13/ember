import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class HabitForm extends StatefulWidget {
  final String? initialName;
  final String? initialUnit;
  final double? initialDailyGoal;
  final String? initialEmoji;
  final String submitButtonText;
  final Future<void> Function(
    String name,
    String unit,
    double dailyGoal,
    String? emoji,
  )
  onSubmit;

  const HabitForm({
    super.key,
    this.initialName,
    this.initialUnit,
    this.initialDailyGoal,
    this.initialEmoji,
    this.submitButtonText = 'Create',
    required this.onSubmit,
  });

  @override
  State<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<HabitForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _unitController;
  late final TextEditingController _goalController;
  late final TextEditingController _emojiController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _unitController = TextEditingController(text: widget.initialUnit);
    _goalController = TextEditingController(
      text: widget.initialDailyGoal?.toString(),
    );
    _emojiController = TextEditingController(text: widget.initialEmoji);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _goalController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: AppStrings.habitName,
              hintText: AppStrings.habitNameHint,
            ),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.validationRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginMd),
          TextFormField(
            controller: _unitController,
            decoration: const InputDecoration(
              labelText: AppStrings.habitUnit,
              hintText: AppStrings.habitUnitHint,
            ),
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.validationRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginMd),
          TextFormField(
            controller: _goalController,
            decoration: const InputDecoration(labelText: AppStrings.dailyGoal),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.validationRequired;
              }
              final number = double.tryParse(value);
              if (number == null || number <= 0) {
                return AppStrings.validationPositiveNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginMd),

          const Spacer(),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitButtonText),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await widget.onSubmit(
      _nameController.text.trim(),
      _unitController.text.trim(),
      double.parse(_goalController.text.trim()),
      _emojiController.text.trim().isEmpty
          ? null
          : _emojiController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
