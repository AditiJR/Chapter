import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/chapter_avatar.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_top_bar.dart';
import '../../widgets/shelf_card.dart';

class FriendProfilePage extends StatefulWidget {
  const FriendProfilePage({super.key, required this.name});

  final String name;

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  bool _following = false;

  static const _pinned = [
    Color(0xff8a4f2a),
    Color(0xff3d5a40),
    Color(0xff2f4858),
    Color(0xff7b2d3b),
    Color(0xff4a3f6b),
  ];

  @override
  Widget build(BuildContext context) {
    final friend = findFriend(widget.name);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ChapterTopBar(title: friend.name, onAction: () {}),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Center(child: ChapterAvatar(tone: friend.tone, size: 88)),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(friend.name, style: ChapterText.headlineMedium),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '@${friend.handle} · Fantasy, fiction, cozy corners',
                      style: ChapterText.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        _Stat(value: '${friend.books}', label: 'Books'),
                        const _Stat(value: '210', label: 'Followers'),
                        const _Stat(value: '98', label: 'Following'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ChapterButton(
                          label: _following ? 'Following' : 'Follow',
                          type: _following
                              ? ChapterButtonType.tonal
                              : ChapterButtonType.filled,
                          onPressed: () =>
                              setState(() => _following = !_following),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChapterButton(
                          label: 'Message',
                          type: ChapterButtonType.outlined,
                          onPressed: () => context.push(
                            '/chat/${Uri.encodeComponent(friend.name)}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Top 5', style: ChapterText.titleLarge),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (var i = 0; i < _pinned.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 61 / 92,
                            child: LayoutBuilder(
                              builder: (context, c) => BookCover(
                                color: _pinned[i],
                                width: c.maxWidth,
                                height: c.maxHeight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Shelves', style: ChapterText.titleLarge),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        child: ShelfCard(name: 'Favorites', count: '12 books'),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ShelfCard(name: 'To be read', count: '31 books'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: ChapterText.titleLarge),
          Text(label, style: ChapterText.bodySmall),
        ],
      ),
    );
  }
}
