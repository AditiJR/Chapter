import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../blocs/library/library_cubit.dart';
import '../../../theme/theme.dart';
import '../../../utilities/guarded.dart';
import '../../../widgets/chapter_bottom_sheet.dart';
import '../../../widgets/chapter_button.dart';
import '../../library/views/new_shelf_sheet.dart';

/// Lets the user pick a shelf. Resolves to the chosen shelf id, or null if
/// dismissed.
Future<String?> showMoveToShelfSheet(
  BuildContext context, {
  String? currentShelfId,
}) {
  return showChapterSheet<String>(
    context,
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    builder: (_) => _MoveToShelfSheet(currentShelfId: currentShelfId),
  );
}

class _MoveToShelfSheet extends StatefulWidget {
  const _MoveToShelfSheet({this.currentShelfId});

  final String? currentShelfId;

  @override
  State<_MoveToShelfSheet> createState() => _MoveToShelfSheetState();
}

class _MoveToShelfSheetState extends State<_MoveToShelfSheet> {
  late String? _selected = widget.currentShelfId;

  Future<void> _newShelf() async {
    final cubit = context.read<LibraryCubit>();
    final name = await showNewShelfSheet(context);
    if (name == null || name.isEmpty || !mounted) return;
    await guarded(context, () => cubit.createShelf(name));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LibraryCubit>().state;
    final shelves = state is LibraryLoaded ? state.shelves : const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Move to shelf', style: ChapterText.titleLarge),
        const SizedBox(height: 8),
        for (final shelf in shelves)
          InkWell(
            onTap: () => setState(() => _selected = shelf.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Row(
                children: [
                  SvgPicture.asset(
                    shelf.id == _selected
                        ? 'assets/icons/radio_on.svg'
                        : 'assets/icons/radio_off.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      shelf.name,
                      style: ChapterText.bodyLarge.copyWith(
                        color: ChapterColors.onSurface,
                      ),
                    ),
                  ),
                  if (shelf.id == _selected)
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
          onTap: _newShelf,
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
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}
