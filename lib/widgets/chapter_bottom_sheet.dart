import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Shows a Chapter-styled modal bottom sheet (28px top corners, drag handle,
/// 40% black scrim) around [builder]'s content.
Future<T?> showChapterSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  EdgeInsets padding = const EdgeInsets.fromLTRB(24, 12, 24, 28),
  Color barrierColor = const Color(0x66000000),
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: ChapterColors.background,
    barrierColor: barrierColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    showDragHandle: false,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const _DragHandle(), builder(context)],
          ),
        ),
      ),
    ),
  );
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ChapterColors.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
