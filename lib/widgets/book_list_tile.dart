import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/book.dart';
import '../theme/theme.dart';
import 'book_cover.dart';

class BookListTile extends StatelessWidget {
  const BookListTile({super.key, required this.book, this.onTap, this.badge});

  final Book book;
  final VoidCallback? onTap;

  /// Text in the pill below the author; defaults to the reading status.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            BookCover(color: book.coverColor, width: 56, height: 84),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: ChapterText.titleMedium),
                  const SizedBox(height: 2),
                  Text(book.author, style: ChapterText.bodyMedium),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ChapterColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge ?? book.status.label,
                      style: ChapterText.labelSmall.copyWith(
                        color: ChapterColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/chevron_right.svg',
              width: 20,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
