import 'package:flutter/material.dart';

import '../../../theme/theme.dart';
import '../../../widgets/chapter_bottom_sheet.dart';
import '../../../widgets/chapter_button.dart';
import '../../../widgets/chapter_chip.dart';

Future<List<String>?> showEditTagsSheet(
  BuildContext context, {
  required List<String> tags,
}) {
  return showChapterSheet<List<String>>(
    context,
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    builder: (_) => _EditTagsSheet(tags: tags),
  );
}

class _EditTagsSheet extends StatefulWidget {
  const _EditTagsSheet({required this.tags});

  final List<String> tags;

  @override
  State<_EditTagsSheet> createState() => _EditTagsSheetState();
}

class _EditTagsSheetState extends State<_EditTagsSheet> {
  late final List<String> _tags = [...widget.tags];
  final _input = TextEditingController();

  static const _suggestions = [
    'Cozy',
    'Dark',
    'Funny',
    'Emotional',
    'Fast-paced',
    'Moderate',
    'Slow-paced',
  ];

  void _add(String tag) {
    final value = tag.trim();
    if (value.isEmpty || _tags.contains(value)) return;
    setState(() => _tags.add(value));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Widget _label(String text) => Text(
    text,
    style: ChapterText.labelLarge.copyWith(
      color: ChapterColors.onSurfaceVariant,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: ChapterText.titleLarge),
        const SizedBox(height: 8),
        _label('On this book'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in _tags)
              ChapterChip(
                label: tag,
                selected: true,
                onTap: () => setState(() => _tags.remove(tag)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _input,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) {
            _add(v);
            _input.clear();
          },
          style: ChapterText.bodyLarge.copyWith(color: ChapterColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Add a tag',
            hintStyle: ChapterText.bodyLarge,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ChapterColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ChapterColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _label('Mood & pace'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in _suggestions)
              ChapterChip(label: s, onTap: () => _add(s)),
          ],
        ),
        const SizedBox(height: 8),
        ChapterButton(
          label: 'Save tags',
          onPressed: () => Navigator.of(context).pop(_tags),
        ),
      ],
    );
  }
}
