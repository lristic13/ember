import 'package:flutter/material.dart';

import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../domain/entities/tracking_type.dart';
import 'tracking_type_option.dart';

class TrackingTypeSelector extends StatelessWidget {
  final TrackingType selected;
  final ValueChanged<TrackingType> onChanged;

  const TrackingTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TrackingTypeOption(
            label: AppStrings.trackingTypeCompletion,
            description: AppStrings.trackingTypeCompletionDesc,
            isSelected: selected == TrackingType.completion,
            onTap: () => onChanged(TrackingType.completion),
          ),
        ),
        const SizedBox(width: AppDimensions.marginSm),
        Expanded(
          child: TrackingTypeOption(
            label: AppStrings.trackingTypeQuantity,
            description: AppStrings.trackingTypeQuantityDesc,
            isSelected: selected == TrackingType.quantity,
            onTap: () => onChanged(TrackingType.quantity),
          ),
        ),
      ],
    );
  }
}
