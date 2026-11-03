import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../model/book.dart';
import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_top_bar.dart';

class EditTopFivePage extends StatefulWidget {
  const EditTopFivePage({super.key});

  @override
  State<EditTopFivePage> createState() => _EditTopFivePageState();
}

class _EditTopFivePageState extends State<EditTopFivePage> {
  static const _maxBooks = 5;

  final _pinned = [...mockTopFive];
  final _candidates = [...mockTopFiveCandidates];

  void _add(Book book) {
    if (_pinned.length >= _maxBooks) return;
    setState(() {
      _pinned.add(book);
      _candidates.remove(book);
    });
  }

  void _remove(Book book) {
    setState(() {
      _pinned.remove(book);
      _candidates.add(book);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ChapterTopBar(title: 'Edit top 5'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text('Pick up to 5 books that say the most about your taste.',
                      style: ChapterText.bodyMedium),
                  const SizedBox(height: 10),
                  for (var i = 0; i < _pinned.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FilledSlot(
                        rank: i + 1,
                        book: _pinned[i],
                        onRemove: () => _remove(_pinned[i]),
                      ),
                    ),
                  if (_pinned.length < _maxBooks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _EmptySlot(
                        rank: _pinned.length + 1,
                        onTap: _candidates.isEmpty
                            ? null
                            : () => _add(_candidates.first),
                      ),
                    ),
                  Text('From your library',
                      style: ChapterText.titleMedium
                          .copyWith(color: ChapterColors.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  for (final book in _candidates)
                    InkWell(
                      onTap: () => _add(book),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            BookCover(
                                color: book.coverColor, width: 40, height: 60),
                            const SizedBox(width: 12),
                            Expanded(child: _BookText(book: book)),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: ChapterColors.outline, width: 2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ChapterButton(
                label: 'Save top 5',
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookText extends StatelessWidget {
  const _BookText({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(book.title,
            style:
                ChapterText.labelLarge.copyWith(color: ChapterColors.onSurface)),
        Text(book.author, style: ChapterText.bodySmall),
      ],
    );
  }
}

class _Rank extends StatelessWidget {
  const _Rank({required this.rank, this.filled = true});

  final int rank;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? ChapterColors.primary : ChapterColors.outlineVariant,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: ChapterText.labelLarge.copyWith(
          color: filled
              ? ChapterColors.onPrimary
              : ChapterColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FilledSlot extends StatelessWidget {
  const _FilledSlot({
    required this.rank,
    required this.book,
    required this.onRemove,
  });

  final int rank;
  final Book book;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ChapterColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Rank(rank: rank),
          const SizedBox(width: 12),
          BookCover(color: book.coverColor, width: 40, height: 60),
          const SizedBox(width: 12),
          Expanded(child: _BookText(book: book)),
          GestureDetector(
            onTap: onRemove,
            child: SvgPicture.asset('assets/icons/x_slot.svg',
                width: 20, height: 20),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.rank, this.onTap});

  final int rank;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: ChapterColors.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _Rank(rank: rank, filled: false),
            const SizedBox(width: 12),
            Expanded(child: Text('Add a book', style: ChapterText.bodyMedium)),
            SvgPicture.asset('assets/icons/plus_slot.svg', width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}
