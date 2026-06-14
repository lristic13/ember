import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/decimal_text_input_formatter.dart';

/// Value input + clear/save buttons for quantity-type habits.
class EntryEditorQuantityContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String? unit;
  final bool isSaving;
  final VoidCallback onClear;
  final VoidCallback onSave;

  const EntryEditorQuantityContent({
    super.key,
    required this.formKey,
    required this.controller,
    required this.unit,
    required this.isSaving,
    required this.onClear,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Value input
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [DecimalTextInputFormatter()],
            decoration: InputDecoration(
              labelText: unit != null
                  ? '${AppStrings.entryValue} ($unit)'
                  : AppStrings.entryValue,
              hintText: '0',
            ),
            autofocus: true,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final parsed = double.tryParse(value.replaceAll(',', '.'));
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
                  onPressed: isSaving ? null : onClear,
                  child: const Text(AppStrings.clear),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSaving ? null : onSave,
                  child: isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
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
