import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/tracking_type.dart';
import 'emoji_picker.dart';
import 'gradient_picker.dart';
import 'tracking_type_selector.dart';

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
  )
  onSubmit;

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
  late String? _selectedEmoji;
  late TrackingType _selectedTrackingType;
  late String _selectedGradientId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _unitController = TextEditingController(text: widget.initialUnit);
    _selectedEmoji = widget.initialEmoji;
    _selectedTrackingType = widget.initialTrackingType;
    _selectedGradientId = widget.initialGradientId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmojiPicker(
                selectedEmoji: _selectedEmoji,
                onChanged: (emoji) => setState(() => _selectedEmoji = emoji),
              ),
              const SizedBox(width: AppDimensions.marginMd),
              Expanded(
                flex: 5,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
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
              ),
              const SizedBox(width: AppDimensions.marginMd),
              Expanded(
                child: GradientPicker(
                  selectedGradientId: _selectedGradientId,
                  onGradientSelected: (gradientId) {
                    setState(() => _selectedGradientId = gradientId);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginLg),
          Text(
            AppStrings.trackingTypeLabel,
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.marginSm),
          TrackingTypeSelector(
            selected: _selectedTrackingType,
            onChanged: (type) => setState(() => _selectedTrackingType = type),
          ),
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
          const SizedBox(height: AppDimensions.marginXl),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.submitButtonText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
      _selectedTrackingType,
      _selectedTrackingType == TrackingType.quantity
          ? _unitController.text.trim()
          : null,
      _selectedEmoji,
      _selectedGradientId,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
