import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../model/social.dart';
import '../../repositories/social/social_repository.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_top_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  bool _isToday(DateTime? t) {
    if (t == null) return true;
    final now = DateTime.now();
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final myUid = context.read<AuthenticationBloc>().user!.uid;
    final social = context.read<SocialRepository>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ChapterTopBar(title: 'Notifications'),
            Expanded(
              child: StreamBuilder<List<AppNotification>>(
                stream: social.watchNotifications(myUid),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return _message('Could not load notifications.\n${snap.error}');
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return _message(
                      'Nothing yet. You will see new followers and messages here.',
                    );
                  }
                  final today = items.where((n) => _isToday(n.createdAt));
                  final earlier = items.where((n) => !_isToday(n.createdAt));
                  Widget item(AppNotification n) => _Item(
                    notification: n,
                    onTap: () {
                      if (!n.read) social.markRead(myUid, n.id);
                      if (n.type == NotificationType.message) {
                        context.push(
                          '/chat/${Uri.encodeComponent(n.fromUid)}',
                          extra: n.fromName,
                        );
                      } else {
                        context.push('/friend/${n.fromUid}');
                      }
                    },
                  );
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (items.any((n) => !n.read))
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => social.markAllRead(myUid),
                            child: const Text('Mark all read'),
                          ),
                        ),
                      if (today.isNotEmpty) ...[
                        _heading('Today'),
                        for (final n in today) item(n),
                      ],
                      if (earlier.isNotEmpty) ...[
                        _heading('Earlier'),
                        for (final n in earlier) item(n),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: ChapterText.bodyMedium,
      ),
    ),
  );

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 2, bottom: 2),
    child: Text(
      text,
      style: ChapterText.labelLarge.copyWith(
        color: ChapterColors.onSurfaceVariant,
      ),
    ),
  );
}

class _Item extends StatelessWidget {
  const _Item({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final icon = n.type == NotificationType.follow
        ? 'assets/icons/user_plus.svg'
        : 'assets/icons/message_small.svg';
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 72,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: ChapterColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(icon, width: 20, height: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: ChapterText.labelLarge.copyWith(
                      fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ChapterText.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              timeAgo(n.createdAt),
              style: ChapterText.labelSmall.copyWith(
                color: ChapterColors.onSurfaceVariant,
              ),
            ),
            if (!n.read) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 4,
                backgroundColor: ChapterColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
