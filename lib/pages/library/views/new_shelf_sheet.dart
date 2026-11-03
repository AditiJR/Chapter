import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/theme.dart';
import '../../../widgets/chapter_bottom_sheet.dart';
import '../../../widgets/chapter_button.dart';
import '../../../widgets/chapter_chip.dart';
import '../../../widgets/chapter_text_field.dart';

Future<String?> showNewShelfSheet(BuildContext context) {
  return showChapterSheet<String>(
    context,
    builder: (_) => const _NewShelfSheet(),
  );
}

class _NewShelfSheet extends StatefulWidget {
  const _NewShelfSheet();

  @override
  State<_NewShelfSheet> createState() => _NewShelfSheetState();
}

class _NewShelfSheetState extends State<_NewShelfSheet> {
  final _name = TextEditingController();

  static const _ideas = ['Favorites', 'DNF', 'Book club'];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New shelf', style: ChapterText.titleLarge),
        const SizedBox(height: 14),
        ChapterTextField(label: 'Shelf name', controller: _name),
        const SizedBox(height: 14),
        Text('Quick ideas',
            style: ChapterText.labelLarge
                .copyWith(color: ChapterColors.onSurfaceVariant)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            for (final idea in _ideas)
              ChapterChip(
                label: idea,
                onTap: () => setState(() => _name.text = idea),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Shelf color',
            style: ChapterText.labelLarge
                .copyWith(color: ChapterColors.onSurfaceVariant)),
        const SizedBox(height: 14),
        SvgPicture.asset('assets/illustrations/color_swatches.svg',
            width: 228, height: 36),
        const SizedBox(height: 14),
        ChapterButton(
          label: 'Create shelf',
          onPressed: () => Navigator.of(context).pop(_name.text.trim()),
        ),
        const SizedBox(height: 8),
        ChapterButton(
          label: 'Cancel',
          type: ChapterButtonType.outlined,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
