import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../model/friend.dart';
import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_avatar.dart';
import '../../widgets/chapter_top_bar.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static final _threads = [
    (friend: mockMaya, preview: 'Did you finish Piranesi yet?', time: '2m', unread: 2, tone: AvatarTone.yellow),
    (friend: mockJordan, preview: 'Adding Klara to my TBR!', time: '1h', unread: 0, tone: AvatarTone.peach),
    (friend: mockPriya, preview: 'That ending though', time: 'Tue', unread: 0, tone: AvatarTone.pink),
    (friend: mockSam, preview: 'Thanks for the rec', time: 'Mon', unread: 0, tone: AvatarTone.yellow),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const ChapterTopBar(title: 'Messages'),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      for (final t in _threads)
                        InkWell(
                          onTap: () => context.push(
                              '/chat/${Uri.encodeComponent(t.friend.name)}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 12),
                            child: Row(
                              children: [
                                ChapterAvatar(tone: t.tone, size: 52),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(t.friend.name,
                                          style: t.unread > 0
                                              ? ChapterText.titleMedium
                                              : ChapterText.titleMedium),
                                      const SizedBox(height: 2),
                                      Text(
                                        t.preview,
                                        style: ChapterText.bodyMedium.copyWith(
                                          color: t.unread > 0
                                              ? ChapterColors.onSurface
                                              : ChapterColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(t.time,
                                        style: ChapterText.labelSmall.copyWith(
                                            color: ChapterColors
                                                .onSurfaceVariant)),
                                    if (t.unread > 0) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: ChapterColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text('${t.unread}',
                                            style: ChapterText.labelSmall
                                                .copyWith(
                                                    color: ChapterColors
                                                        .onPrimary)),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 24,
              child: Material(
                color: ChapterColors.primaryContainer,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 20, 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/icons/pencil_small.svg',
                            width: 22, height: 22),
                        const SizedBox(width: 10),
                        Text('New message',
                            style: ChapterText.labelLarge.copyWith(
                                color: ChapterColors.onPrimaryContainer)),
                      ],
                    ),
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
