import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'gradient_picker.dart';

class HabitForm extends StatefulWidget {
  final String? initialName;
  final String? initialUnit;
  final String? initialEmoji;
  final String initialGradientId;
  final String submitButtonText;
  final Future<void> Function(
    String name,
    String unit,
    String? emoji,
    String gradientId,
  )
  onSubmit;

  const HabitForm({
    super.key,
    this.initialName,
    this.initialUnit,
    this.initialEmoji,
    this.initialGradientId = 'ember',
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
  late final TextEditingController _emojiController;
  late String _selectedGradientId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _unitController = TextEditingController(text: widget.initialUnit);
    _emojiController = TextEditingController(text: widget.initialEmoji);
    _selectedGradientId = widget.initialGradientId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
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
              labelText: AppStrings.activityName,
              hintText: AppStrings.activityNameHint,
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
              labelText: AppStrings.activityUnit,
              hintText: AppStrings.activityUnitHint,
            ),
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.validationRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginLg),
          Text(
            'Color',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSm),
          GradientPicker(
            selectedGradientId: _selectedGradientId,
            onGradientSelected: (gradientId) {
              setState(() => _selectedGradientId = gradientId);
            },
          ),
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
      _emojiController.text.trim().isEmpty
          ? null
          : _emojiController.text.trim(),
      _selectedGradientId,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
