import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action = "See all",
    this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(child: Text(title, style: ChapterText.titleLarge)),
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: ChapterText.labelLarge.copyWith(
                color: ChapterColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
