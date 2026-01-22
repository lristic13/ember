import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/tracking_type.dart';
import 'gradient_picker.dart';

class HabitForm extends StatefulWidget {
  final String? initialName;
  final TrackingType initialTrackingType;
  final String? initialUnit;
  final String? initialEmoji;
  final String initialGradientId;
  final String submitButtonText;
  final Future<void> Function(
    String name,
    TrackingType trackingType,
    String? unit,
    String? emoji,
    String gradientId,
  ) onSubmit;

  const HabitForm({
    super.key,
    this.initialName,
    this.initialTrackingType = TrackingType.quantity,
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
  late TrackingType _selectedTrackingType;
  late String _selectedGradientId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _unitController = TextEditingController(text: widget.initialUnit);
    _emojiController = TextEditingController(text: widget.initialEmoji);
    _selectedTrackingType = widget.initialTrackingType;
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
    final theme = Theme.of(context);
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
          const SizedBox(height: AppDimensions.marginLg),
          Text(
            AppStrings.trackingTypeLabel,
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.marginSm),
          _buildTrackingTypeSelector(),
          if (_selectedTrackingType == TrackingType.quantity) ...[
            const SizedBox(height: AppDimensions.marginMd),
            TextFormField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: AppStrings.activityUnit,
                hintText: AppStrings.activityUnitHint,
              ),
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (_selectedTrackingType == TrackingType.quantity &&
                    (value == null || value.trim().isEmpty)) {
                  return AppStrings.validationRequired;
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: AppDimensions.marginLg),
          Text(
            AppStrings.colorLabel,
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.marginSm),
          GradientPicker(
            selectedGradientId: _selectedGradientId,
            onGradientSelected: (gradientId) {
              setState(() => _selectedGradientId = gradientId);
            },
          ),
          const SizedBox(height: AppDimensions.marginXl),
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

  Widget _buildTrackingTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TrackingTypeOption(
            label: AppStrings.trackingTypeCompletion,
            description: AppStrings.trackingTypeCompletionDesc,
            isSelected: _selectedTrackingType == TrackingType.completion,
            onTap: () => setState(() => _selectedTrackingType = TrackingType.completion),
          ),
        ),
        const SizedBox(width: AppDimensions.marginSm),
        Expanded(
          child: _TrackingTypeOption(
            label: AppStrings.trackingTypeQuantity,
            description: AppStrings.trackingTypeQuantityDesc,
            isSelected: _selectedTrackingType == TrackingType.quantity,
            onTap: () => setState(() => _selectedTrackingType = TrackingType.quantity),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await widget.onSubmit(
      _nameController.text.trim(),
      _selectedTrackingType,
      _selectedTrackingType == TrackingType.quantity
          ? _unitController.text.trim()
          : null,
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

class _TrackingTypeOption extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _TrackingTypeOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: AppDimensions.marginXs),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
