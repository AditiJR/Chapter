import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../model/book.dart';
import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/book_actions.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_chip.dart';
import '../../widgets/chapter_dialog.dart';
import 'views/buy_sheet.dart';
import 'views/edit_tags_sheet.dart';
import 'views/move_to_shelf_sheet.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.title});

  final String title;

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late final Book _book = findBook(widget.title);
  late List<String> _tags = _book.tags;
  late ReadingStatus _shelf = _book.status;

  Future<void> _moveToShelf() async {
    final result = await showMoveToShelfSheet(context, current: _shelf);
    if (result != null && mounted) setState(() => _shelf = result);
  }

  Future<void> _editTags() async {
    final result = await showEditTagsSheet(context, tags: _tags);
    if (result != null && mounted) setState(() => _tags = result);
  }

  void _pin() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ChapterColors.onSurface,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Pinned to your Top 5',
            style: ChapterText.bodyMedium
                .copyWith(color: ChapterColors.background),
          ),
          action: SnackBarAction(
            label: 'View',
            textColor: ChapterColors.primaryContainer,
            onPressed: () {},
          ),
        ),
      );
  }

  Future<void> _remove() async {
    final confirmed = await showChapterDialog<bool>(
      context,
      icon: SvgPicture.asset('assets/icons/trash_large.svg',
          width: 28, height: 28),
      title: 'Remove “${_book.title}”?',
      body: 'It will be removed from all your shelves and your top 5.',
      actions: [
        DialogAction(
          label: 'Cancel',
          onTap: () => Navigator.of(context).pop(false),
        ),
        DialogAction(
          label: 'Remove',
          filledColor: ChapterColors.error,
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset('assets/icons/arrow_left.svg',
                          width: 24, height: 24),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset('assets/icons/more.svg',
                        width: 24, height: 24),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: BookCover(
                        color: _book.coverColor,
                        title: _book.title,
                        author: _book.author,
                        width: 132,
                        height: 198,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        _book.title,
                        textAlign: TextAlign.center,
                        style: ChapterText.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        [
                          _book.author,
                          if (_book.pages != null) '${_book.pages} pages',
                        ].join(' · '),
                        textAlign: TextAlign.center,
                        style: ChapterText.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 14),
                    BookActions(
                      onShelf: _moveToShelf,
                      onTags: _editTags,
                      onPin: _pin,
                      onRemove: _remove,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in _tags)
                          ChapterChip(label: tag, selected: true),
                      ],
                    ),
                    if (_book.about != null) ...[
                      const SizedBox(height: 14),
                      Text('About', style: ChapterText.titleLarge),
                      const SizedBox(height: 14),
                      Text(_book.about!, style: ChapterText.bodyMedium),
                    ],
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  ChapterButton(
                    label: 'Buy this book',
                    onPressed: () => showBuySheet(context, _book),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Opens Bookshop.org or Amazon. Chapter may earn a commission.',
                    textAlign: TextAlign.center,
                    style: ChapterText.labelSmall
                        .copyWith(color: ChapterColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
