import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../model/book.dart';
import '../../../services/mock.dart';
import '../../../theme/theme.dart';
import '../../../widgets/book_cover.dart';
import '../../../widgets/chapter_bottom_sheet.dart';
import '../../../widgets/chapter_button.dart';
import '../../../widgets/chapter_chip.dart';

/// Shelf order used by chips and radio lists.
const shelfOrder = [
  ReadingStatus.reading,
  ReadingStatus.finished,
  ReadingStatus.toBeRead,
  ReadingStatus.dnf,
];

Future<void> showScanResultSheet(BuildContext context) {
  return showChapterSheet<void>(
    context,
    barrierColor: const Color(0x4D000000),
    builder: (_) => _ScanResultSheet(parentContext: context),
  );
}

class _ScanResultSheet extends StatefulWidget {
  const _ScanResultSheet({required this.parentContext});

  /// Context of the scan page, used to navigate after the sheet closes.
  final BuildContext parentContext;

  @override
  State<_ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends State<_ScanResultSheet> {
  ReadingStatus _shelf = ReadingStatus.finished;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book found',
          style: ChapterText.labelLarge.copyWith(color: ChapterColors.success),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            BookCover(
              color: piranesi.coverColor,
              title: piranesi.title,
              author: piranesi.author,
              width: 84,
              height: 126,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(piranesi.title, style: ChapterText.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${piranesi.author} · ${piranesi.year}',
                    style: ChapterText.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ISBN 9781635575637',
                    style: ChapterText.labelMedium.copyWith(
                      color: ChapterColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Source: Google Books',
                    style: ChapterText.labelSmall.copyWith(
                      color: ChapterColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Add to shelf',
          style: ChapterText.labelLarge.copyWith(
            color: ChapterColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: [
            for (final status in shelfOrder)
              ChapterChip(
                label: status.label,
                selected: status == _shelf,
                onTap: () => setState(() => _shelf = status),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ChapterButton(
          label: 'Add to library',
          onPressed: () {
            Navigator.of(context).pop();
            widget.parentContext.push(
              '/book/${Uri.encodeComponent(piranesi.title)}',
            );
          },
        ),
        const SizedBox(height: 8),
        ChapterButton(
          label: 'Scan again',
          type: ChapterButtonType.outlined,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
