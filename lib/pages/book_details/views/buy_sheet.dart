import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../model/book.dart';
import '../../../theme/theme.dart';
import '../../../widgets/chapter_bottom_sheet.dart';

Future<void> showBuySheet(BuildContext context, Book book) {
  return showChapterSheet<void>(
    context,
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    builder: (_) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Buy ${book.title}', style: ChapterText.titleLarge),
        const SizedBox(height: 8),
        const _StoreRow(
          letter: 'B',
          color: ChapterColors.primary,
          name: 'Bookshop.org',
          caption: 'Supports independent bookstores',
          price: r'$16.99',
        ),
        const SizedBox(height: 8),
        const _StoreRow(
          letter: 'A',
          color: ChapterColors.secondary,
          name: 'Amazon',
          caption: 'Fast delivery',
          price: r'$14.20',
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Text(
            'Chapter may earn a commission from purchases, at no extra cost to you.',
            textAlign: TextAlign.center,
            style: ChapterText.labelSmall
                .copyWith(color: ChapterColors.onSurfaceVariant),
          ),
        ),
      ],
    ),
  );
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.letter,
    required this.color,
    required this.name,
    required this.caption,
    required this.price,
  });

  final String letter;
  final Color color;
  final String name;
  final String caption;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChapterColors.surfaceContainer,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(letter,
                    style: ChapterText.titleMedium
                        .copyWith(color: ChapterColors.onPrimary)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: ChapterText.titleMedium),
                    const SizedBox(height: 2),
                    Text(caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ChapterText.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Text(price,
                  style: ChapterText.titleMedium
                      .copyWith(color: ChapterColors.primary)),
              const SizedBox(width: 14),
              SvgPicture.asset('assets/icons/external.svg',
                  width: 18, height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
