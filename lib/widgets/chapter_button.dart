import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum ChapterButtonType { filled, outlined, tonal }

class ChapterButton extends StatelessWidget {
  const ChapterButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ChapterButtonType.filled,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ChapterButtonType type;

  /// Shows a spinner and ignores taps while true.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final filled = type == ChapterButtonType.filled;
    final tonal = type == ChapterButtonType.tonal;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: filled
            ? ChapterColors.primary
            : tonal
            ? ChapterColors.secondaryContainer
            : Colors.transparent,
        shape: StadiumBorder(
          side: filled || tonal
              ? BorderSide.none
              : const BorderSide(color: ChapterColors.outline),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: loading ? null : onPressed,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: filled
                          ? ChapterColors.onPrimary
                          : ChapterColors.primary,
                    ),
                  )
                : Text(
                    label,
                    style: ChapterText.labelLarge.copyWith(
                      color: filled
                          ? ChapterColors.onPrimary
                          : tonal
                          ? ChapterColors.onSecondaryContainer
                          : ChapterColors.primary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
