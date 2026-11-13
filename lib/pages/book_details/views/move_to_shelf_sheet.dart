import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../model/book.dart';
import '../../../theme/theme.dart';
import '../../../widgets/chapter_bottom_sheet.dart';
import '../../../widgets/chapter_button.dart';
import '../../library/views/new_shelf_sheet.dart';
import '../../scan/views/scan_result_sheet.dart' show shelfOrder;

Future<ReadingStatus?> showMoveToShelfSheet(
  BuildContext context, {
  required ReadingStatus current,
}) {
  return showChapterSheet<ReadingStatus>(
    context,
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    builder: (_) => _MoveToShelfSheet(current: current),
  );
}

class _MoveToShelfSheet extends StatefulWidget {
  const _MoveToShelfSheet({required this.current});

  final ReadingStatus current;

  @override
  State<_MoveToShelfSheet> createState() => _MoveToShelfSheetState();
}

class _MoveToShelfSheetState extends State<_MoveToShelfSheet> {
  late ReadingStatus _selected = widget.current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Move to shelf', style: ChapterText.titleLarge),
        const SizedBox(height: 8),
        for (final status in shelfOrder)
          InkWell(
            onTap: () => setState(() => _selected = status),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Row(
                children: [
                  SvgPicture.asset(
                    status == _selected
                        ? 'assets/icons/radio_on.svg'
                        : 'assets/icons/radio_off.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      status.label,
                      style: ChapterText.bodyLarge.copyWith(
                        color: ChapterColors.onSurface,
                      ),
                    ),
                  ),
                  if (status == _selected)
                    SvgPicture.asset(
                      'assets/icons/check.svg',
                      width: 22,
                      height: 22,
                    ),
                ],
              ),
            ),
          ),
        InkWell(
          onTap: () => showNewShelfSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/plus.svg',
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  'New shelf',
                  style: ChapterText.bodyLarge.copyWith(
                    color: ChapterColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ChapterButton(
          label: 'Done',
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}
