import 'package:flutter/material.dart';

import '../model/friend.dart';
import '../model/user_profile.dart';
import '../theme/theme.dart';
import 'chapter_avatar.dart';

/// Avatar + name/handle + Follow toggle for a real user.
class UserRow extends StatelessWidget {
  const UserRow({
    super.key,
    required this.profile,
    required this.following,
    required this.onToggleFollow,
    this.onTap,
  });

  final UserProfile profile;
  final bool following;
  final VoidCallback onToggleFollow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            ChapterAvatar(tone: toneFor(profile.uid), size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ChapterText.titleMedium,
                  ),
                  Text(profile.handle, style: ChapterText.bodySmall),
                ],
              ),
            ),
            GestureDetector(
              onTap: onToggleFollow,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: following
                      ? ChapterColors.secondaryContainer
                      : Colors.transparent,
                  border: following
                      ? null
                      : Border.all(color: ChapterColors.outline),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  following ? 'Following' : 'Follow',
                  style: ChapterText.labelLarge.copyWith(
                    color: following
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
