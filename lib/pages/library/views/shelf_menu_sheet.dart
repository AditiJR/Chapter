import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/theme.dart';
import '../../../widgets/chapter_bottom_sheet.dart';

enum ShelfMenuAction { edit, changeCover, delete }

Future<ShelfMenuAction?> showShelfMenuSheet(
  BuildContext context, {
  required String shelfName,
}) {
  return showChapterSheet<ShelfMenuAction>(
    context,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Text(shelfName, style: ChapterText.titleLarge),
        ),
        _MenuRow(
          icon: 'assets/icons/pencil.svg',
          label: 'Edit shelf',
          onTap: () => Navigator.of(context).pop(ShelfMenuAction.edit),
        ),
        _MenuRow(
          icon: 'assets/icons/crown.svg',
          label: 'Change shelf cover',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: ChapterColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Premium',
              style: ChapterText.labelSmall.copyWith(
                color: ChapterColors.onTertiaryContainer,
              ),
            ),
          ),
          onTap: () => Navigator.of(context).pop(ShelfMenuAction.changeCover),
        ),
        _MenuRow(
          icon: 'assets/icons/trash.svg',
          label: 'Delete shelf',
          color: ChapterColors.error,
          onTap: () => Navigator.of(context).pop(ShelfMenuAction.delete),
        ),
      ],
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.color = ChapterColors.onSurface,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 24, height: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: ChapterText.bodyLarge.copyWith(color: color),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
