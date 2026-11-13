import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Chapter-styled alert dialog: 28px radius, surface-container-high fill,
/// optional leading [icon], Lora title, body text and right-aligned actions.
Future<T?> showChapterDialog<T>(
  BuildContext context, {
  Widget? icon,
  required String title,
  required String body,
  required List<Widget> actions,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: const Color(0x66000000),
    builder: (context) => Dialog(
      backgroundColor: ChapterColors.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 312),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[icon, const SizedBox(height: 16)],
              Text(title, style: ChapterText.titleLarge),
              const SizedBox(height: 16),
              Text(body, style: ChapterText.bodyMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    actions[i],
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Pill-shaped dialog action. [filledColor] makes it a filled (e.g. error) button.
class DialogAction extends StatelessWidget {
  const DialogAction({
    super.key,
    required this.label,
    required this.onTap,
    this.filledColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color? filledColor;

  @override
  Widget build(BuildContext context) {
    final filled = filledColor != null;
    return Material(
      color: filledColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: filled ? 20 : 16,
            vertical: 10,
          ),
          child: Text(
            label,
            style: ChapterText.labelLarge.copyWith(
              color: filled ? ChapterColors.onPrimary : ChapterColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
