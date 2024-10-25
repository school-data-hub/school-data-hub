import 'package:flutter/material.dart';
import 'package:schuldaten_hub/common/constants/colors.dart';
import 'package:schuldaten_hub/common/constants/styles.dart';

class ThemedFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const ThemedFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      autofocus: true,
      elevation: 0,
      pressElevation: 0,
      padding: filterChipPadding,
      labelPadding: filterChipLabelPadding,
      shape: filterChipShape,
      avatar: const CircleAvatar(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 10,
        ),
      ),
      selectedColor: filterChipSelectedColor,
      checkmarkColor: filterChipSelectedCheckColor,
      backgroundColor: filterChipUnselectedColor,
      label: Text(
        label,
        style: filterItemsTextStyle,
      ),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
