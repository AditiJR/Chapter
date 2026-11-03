import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ChapterChip extends StatelessWidget {
  const ChapterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ChapterColors.secondaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: selected
            ? BorderSide.none
            : const BorderSide(color: ChapterColors.outline),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: ChapterText.labelLarge.copyWith(
                color: selected
                    ? ChapterColors.onSecondaryContainer
                    : ChapterColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
