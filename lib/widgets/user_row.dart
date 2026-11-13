import 'package:flutter/material.dart';

import '../model/friend.dart';
import '../theme/theme.dart';
import 'chapter_avatar.dart';

/// Avatar + name/handle + Follow toggle.
class UserRow extends StatefulWidget {
  const UserRow({super.key, required this.friend, this.onTap});

  final Friend friend;
  final VoidCallback? onTap;

  @override
  State<UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<UserRow> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            ChapterAvatar(tone: widget.friend.tone, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.friend.name, style: ChapterText.titleMedium),
                  Text(widget.friend.summary, style: ChapterText.bodySmall),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _following = !_following),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _following
                      ? ChapterColors.secondaryContainer
                      : Colors.transparent,
                  border: _following
                      ? null
                      : Border.all(color: ChapterColors.outline),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _following ? 'Following' : 'Follow',
                  style: ChapterText.labelLarge.copyWith(
                    color: _following
                        ? ChapterColors.onSecondaryContainer
                        : ChapterColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
