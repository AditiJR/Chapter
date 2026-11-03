import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';

/// Row of four tiles on the book details screen (Shelf, Tags, Pin, Remove).
class BookActions extends StatelessWidget {
  const BookActions({
    super.key,
    required this.onShelf,
    required this.onTags,
    required this.onPin,
    required this.onRemove,
  });

  final VoidCallback onShelf;
  final VoidCallback onTags;
  final VoidCallback onPin;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: 'assets/icons/bookmark.svg',
            label: 'Shelf',
            highlighted: true,
            onTap: onShelf,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            icon: 'assets/icons/tag.svg',
            label: 'Tags',
            onTap: onTags,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            icon: 'assets/icons/pin.svg',
            label: 'Pin to top 5',
            onTap: onPin,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionTile(
            icon: 'assets/icons/trash_small.svg',
            label: 'Remove',
            onTap: onRemove,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted
          ? ChapterColors.primaryContainer
          : ChapterColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              SvgPicture.asset(icon, width: 22, height: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: ChapterText.labelMedium.copyWith(
                  color: highlighted
                      ? ChapterColors.onPrimaryContainer
                      : ChapterColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
