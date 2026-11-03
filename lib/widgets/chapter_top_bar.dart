import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';

/// Back arrow + Lora title row used on pushed screens.
class ChapterTopBar extends StatelessWidget {
  const ChapterTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.onAction,
  });

  final String title;
  final VoidCallback? onBack;

  /// When set, a trailing "more" icon button is shown.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 8),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack ?? () => context.pop(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset('assets/icons/arrow_left.svg',
                  width: 24, height: 24),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(title, style: ChapterText.titleLarge)),
          if (onAction != null)
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset('assets/icons/more.svg',
                    width: 24, height: 24),
              ),
            ),
        ],
      ),
    );
  }
}
