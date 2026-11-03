import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/theme.dart';
import '../../../widgets/chapter_dialog.dart';

/// Resolves to true when the user confirms the delete.
Future<bool> showDeleteShelfDialog(
  BuildContext context, {
  required String shelfName,
  required int bookCount,
}) async {
  final result = await showChapterDialog<bool>(
    context,
    icon: SvgPicture.asset('assets/icons/trash_large.svg',
        width: 28, height: 28),
    title: 'Delete “$shelfName”?',
    body:
        "The $bookCount books stay in your library. Only the shelf is removed. This can't be undone.",
    actions: [
      DialogAction(
        label: 'Cancel',
        onTap: () => Navigator.of(context).pop(false),
      ),
      DialogAction(
        label: 'Delete',
        filledColor: ChapterColors.error,
        onTap: () => Navigator.of(context).pop(true),
      ),
    ],
  );
  return result ?? false;
}
