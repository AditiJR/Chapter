import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../model/book.dart';
import '../../../theme/theme.dart';
import '../../../widgets/book_cover.dart';
import '../../../widgets/chapter_bottom_sheet.dart';
import '../../../widgets/chapter_button.dart';
import '../../../widgets/chapter_chip.dart';
import '../../../blocs/library/library_cubit.dart';
import '../../../utilities/guarded.dart';

Future<void> showScanResultSheet(BuildContext context, Book book) {
  return showChapterSheet<void>(
    context,
    barrierColor: const Color(0x4D000000),
    builder: (_) => _ScanResultSheet(parentContext: context, book: book),
  );
}

class _ScanResultSheet extends StatefulWidget {
  const _ScanResultSheet({required this.parentContext, required this.book});

  /// The book returned by the ISBN lookup.
  final Book book;

  /// Context of the scan page, used to navigate after the sheet closes.
  final BuildContext parentContext;

  @override
  State<_ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends State<_ScanResultSheet> {
  String _shelfId = ReadingStatus.finished.shelfId;

  Future<void> _add() async {
    final cubit = context.read<LibraryCubit>();
    final parent = widget.parentContext;
    final book = widget.book;
    Navigator.of(context).pop();
    await guarded(parent, () => cubit.addBook(book, shelfId: _shelfId));
    if (parent.mounted) {
      parent.push('/book/${Uri.encodeComponent(book.title)}', extra: book);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LibraryCubit>().state;
    final shelves = state is LibraryLoaded ? state.shelves : const [];
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
              color: widget.book.coverColor,
              title: widget.book.title,
              author: widget.book.author,
              width: 84,
              height: 126,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.book.title, style: ChapterText.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.book.author}${widget.book.year != null ? ' · ${widget.book.year}' : ''}',
                    style: ChapterText.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ISBN ${widget.book.isbn ?? 'unknown'}',
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
            for (final shelf in shelves)
              ChapterChip(
                label: shelf.name,
                selected: shelf.id == _shelfId,
                onTap: () => setState(() => _shelfId = shelf.id),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ChapterButton(label: 'Add to library', onPressed: _add),
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
