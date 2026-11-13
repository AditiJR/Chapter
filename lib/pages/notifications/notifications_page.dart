import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../widgets/chapter_top_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ChapterTopBar(title: 'Notifications'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _heading('Today'),
                  _Item(
                    icon: 'assets/icons/user_plus.svg',
                    title: 'Priya Nair followed you',
                    subtitle: '@priya · 211 books',
                    time: '2m',
                    onTap: () => context.push('/friend/Priya%20Nair'),
                  ),
                  _Item(
                    icon: 'assets/icons/message_small.svg',
                    title: 'Maya Chen sent a message',
                    subtitle: 'Did you finish Piranesi yet?',
                    time: '5m',
                    onTap: () => context.push('/chat/Maya%20Chen'),
                  ),
                  _Item(
                    icon: 'assets/icons/book_open_small.svg',
                    title: 'Jordan Lee shelved Klara and the Sun',
                    subtitle: 'On their Currently reading shelf',
                    time: '1h',
                    onTap: () => context.push('/friend/Jordan%20Lee'),
                  ),
                  _heading('Earlier'),
                  _Item(
                    icon: 'assets/icons/user_plus.svg',
                    title: 'Sam Ortiz followed you',
                    subtitle: '@samreads · 96 books',
                    time: 'Tue',
                    onTap: () => context.push('/friend/Sam%20Ortiz'),
                  ),
                  const _Item(
                    icon: 'assets/icons/star.svg',
                    title: 'You hit 20 books this year',
                    subtitle: 'Nice reading streak!',
                    time: 'Mon',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
  const _Item({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                  Text(title, style: ChapterText.labelLarge),
                  const SizedBox(height: 2),
                  Text(subtitle, style: ChapterText.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              time,
              style: ChapterText.labelSmall.copyWith(
                color: ChapterColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
