import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/theme.dart';
import '../../../widgets/book_cover.dart';

class _IllustrationFrame extends StatelessWidget {
  const _IllustrationFrame({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}

class ScanIllustration extends StatelessWidget {
  const ScanIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return _IllustrationFrame(
      color: ChapterColors.primaryContainer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const BookCover(
            color: Color(0xff3d5940),
            title: 'Piranesi',
            author: 'Susanna Clarke',
            width: 120,
            height: 180,
          ),
          SvgPicture.asset('assets/icons/scan.svg', width: 220, height: 220),
          Container(
            width: 190,
            height: 3,
            decoration: BoxDecoration(
              color: ChapterColors.error,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class ShelvesIllustration extends StatelessWidget {
  const ShelvesIllustration({super.key});

  // (color, height) per book, row by row.
  static const _rows = [
    [
      (Color(0xff7b2d3b), 60.0),
      (Color(0xff2f4858), 68.0),
      (Color(0xff3d5a40), 56.0),
      (Color(0xff8a4f2a), 66.0),
    ],
    [
      (Color(0xff2f4858), 68.0),
      (Color(0xff3d5a40), 56.0),
      (Color(0xff8a4f2a), 66.0),
      (Color(0xff6b5e2f), 62.0),
      (Color(0xff4a3f6b), 58.0),
    ],
    [
      (Color(0xff3d5a40), 56.0),
      (Color(0xff8a4f2a), 66.0),
      (Color(0xff6b5e2f), 62.0),
      (Color(0xff4a3f6b), 58.0),
    ],
  ];
  static const _rowTops = [40.0, 130.0, 220.0];
  static const _plankTops = [110.0, 200.0, 290.0];

  @override
  Widget build(BuildContext context) {
    return _IllustrationFrame(
      color: ChapterColors.tertiaryContainer,
      child: Stack(
        children: [
          for (var r = 0; r < _rows.length; r++)
            Positioned(
              left: 40,
              top: _rowTops[r],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var b = 0; b < _rows[r].length; b++) ...[
                    if (b > 0) const SizedBox(width: 8),
                    Container(
                      width: 34,
                      height: _rows[r][b].$2,
                      decoration: BoxDecoration(
                        color: _rows[r][b].$1,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          for (final top in _plankTops)
            Positioned(
              left: 40,
              top: top,
              child: Container(
                width: 265,
                height: 8,
                decoration: BoxDecoration(
                  color: ChapterColors.secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FriendsIllustration extends StatelessWidget {
  const FriendsIllustration({super.key});

  Widget _bubble(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(text, style: ChapterText.bodyMedium.copyWith(color: fg)),
  );

  @override
  Widget build(BuildContext context) {
    return _IllustrationFrame(
      color: ChapterColors.secondaryContainer,
      child: Stack(
        children: [
          Positioned(
            left: 95,
            top: 70,
            child: SvgPicture.asset(
              'assets/illustrations/avatar_1.svg',
              width: 84,
              height: 84,
            ),
          ),
          Positioned(
            left: 153,
            top: 110,
            child: SvgPicture.asset(
              'assets/illustrations/avatar_2.svg',
              width: 84,
              height: 84,
            ),
          ),
          Positioned(
            left: 211,
            top: 70,
            child: SvgPicture.asset(
              'assets/illustrations/avatar_3.svg',
              width: 84,
              height: 84,
            ),
          ),
          Positioned(
            left: 60,
            top: 210,
            child: _bubble(
              'Just finished it. Wow.',
              ChapterColors.onSecondaryContainer,
              ChapterColors.onPrimary,
            ),
          ),
          Positioned(
            left: 130,
            top: 258,
            child: _bubble(
              'Adding it to my shelf!',
              ChapterColors.background,
              ChapterColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
