import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A book cover with a darker spine strip. When [title] is null only the
/// colored cover and spine are drawn (used in list rows).
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.color,
    this.title,
    this.author,
    this.width = 96,
    this.height = 144,
  });

  final Color color;
  final String? title;
  final String? author;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: ChapterText.lora(
                      13,
                      16,
                      FontWeight.w700,
                      color: ChapterColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (author != null)
                    Opacity(
                      opacity: 0.85,
                      child: Text(
                        author!,
                        style: ChapterText.roboto(
                          9,
                          12,
                          FontWeight.w400,
                          color: ChapterColors.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 6, color: const Color(0x33000000)),
          ),
        ],
      ),
    );
  }
}
