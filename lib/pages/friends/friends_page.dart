import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../model/friend.dart';
import '../../navigation/my_navigator_route.dart';
import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/chapter_avatar.dart';
import '../../widgets/chapter_chip.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/user_row.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  static const _tabs = ['Activity', 'Following', 'Followers'];
  String _tab = 'Activity';

  void _openProfile(Friend f) =>
      context.push('/friend/${Uri.encodeComponent(f.name)}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Friends', style: ChapterText.headlineMedium),
                ),
                CircleIconButton(
                  icon: 'assets/icons/message.svg',
                  onTap: () => context.push(MyNavigatorRoute.messages.path),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: ChapterColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/search_find.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Find readers by name or @handle',
                    style: ChapterText.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [
                for (final t in _tabs)
                  ChapterChip(
                    label: t,
                    selected: t == _tab,
                    onTap: () => setState(() => _tab = t),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (_tab == 'Activity') ...[
              _ActivityCard(
                friend: mockMaya,
                avatarSize: 36,
                title: 'Maya Chen shelved a book on Favorites',
                time: '2h ago',
                bookTitle: 'Circe',
                bookAuthor: 'Madeline Miller',
                coverColor: const Color(0xff8a4f2a),
                onTap: () => _openProfile(mockMaya),
              ),
              const SizedBox(height: 14),
              _ActivityCard(
                friend: mockJordan,
                avatarSize: 36,
                title: 'Jordan Lee started reading',
                time: 'Yesterday',
                bookTitle: 'Klara and the Sun',
                bookAuthor: 'Kazuo Ishiguro',
                coverColor: const Color(0xff6b5e2f),
                onTap: () => _openProfile(mockJordan),
              ),
              const SizedBox(height: 14),
              const SectionHeader(title: 'Suggested readers'),
              const SizedBox(height: 14),
              UserRow(
                friend: mockPriya.copyAs(AvatarTone.yellow),
                onTap: () => _openProfile(mockPriya),
              ),
              const SizedBox(height: 14),
              UserRow(friend: mockSam, onTap: () => _openProfile(mockSam)),
            ] else
              for (final f in mockFriends)
                UserRow(friend: f, onTap: () => _openProfile(f)),
          ],
        ),
      ),
    );
  }
}

extension on Friend {
  Friend copyAs(AvatarTone tone) =>
      Friend(name: name, handle: handle, books: books, tone: tone);
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.friend,
    required this.avatarSize,
    required this.title,
    required this.time,
    required this.bookTitle,
    required this.bookAuthor,
    required this.coverColor,
    required this.onTap,
  });

  final Friend friend;
  final int avatarSize;
  final String title;
  final String time;
  final String bookTitle;
  final String bookAuthor;
  final Color coverColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChapterColors.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ChapterAvatar(tone: friend.tone, size: avatarSize),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: ChapterText.labelLarge),
                        Text(time, style: ChapterText.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  BookCover(color: coverColor, width: 56, height: 84),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookTitle, style: ChapterText.titleMedium),
                        const SizedBox(height: 2),
                        Text(bookAuthor, style: ChapterText.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
