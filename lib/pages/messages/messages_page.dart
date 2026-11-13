import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../model/chat.dart';
import '../../model/friend.dart';
import '../../repositories/chat/chat_repository.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_avatar.dart';
import '../../widgets/chapter_top_bar.dart';
import 'views/new_message_sheet.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  static String _time(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (t.year == now.year && t.month == now.month && t.day == now.day) {
      return '${diff.inHours}h';
    }
    if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[t.weekday - 1];
    }
    return '${t.month}/${t.day}';
  }

  @override
  Widget build(BuildContext context) {
    final me = context.read<AuthenticationBloc>().user!;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const ChapterTopBar(title: 'Messages'),
                Expanded(
                  child: StreamBuilder<List<ChatThread>>(
                    stream: context.read<ChatRepository>().watchChats(me.uid),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Could not load messages.\n${snap.error}',
                            textAlign: TextAlign.center,
                            style: ChapterText.bodyMedium,
                          ),
                        );
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final threads = snap.data!;
                      if (threads.isEmpty) {
                        return Center(
                          child: Text(
                            'No conversations yet.\nTap New message to start one.',
                            textAlign: TextAlign.center,
                            style: ChapterText.bodyMedium,
                          ),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        children: [
                          for (final t in threads)
                            InkWell(
                              onTap: () => context.push(
                                '/chat/${Uri.encodeComponent(t.otherUid(me.uid))}',
                                extra: t.otherName(me.uid),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    const ChapterAvatar(
                                      tone: AvatarTone.peach,
                                      size: 52,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.otherName(me.uid),
                                            style: ChapterText.titleMedium,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            t.lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: ChapterText.bodyMedium
                                                .copyWith(
                                                  color: ChapterColors
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _time(t.lastMessageAt!),
                                      style: ChapterText.labelSmall.copyWith(
                                        color: ChapterColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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
                  onTap: () => showNewMessageSheet(context),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 20, 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/pencil_small.svg',
                          width: 22,
                          height: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'New message',
                          style: ChapterText.labelLarge.copyWith(
                            color: ChapterColors.onPrimaryContainer,
                          ),
                        ),
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
