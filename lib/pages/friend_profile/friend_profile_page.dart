import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../model/book.dart';
import '../../model/friend.dart';
import '../../model/shelf.dart';
import '../../model/user_profile.dart';
import '../../repositories/library/library_repository.dart';
import '../../repositories/social/social_repository.dart';
import '../../repositories/users/user_repository.dart';
import '../../theme/theme.dart';
import '../../utilities/guarded.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/chapter_avatar.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_top_bar.dart';
import '../../widgets/shelf_card.dart';

/// Another reader's profile, read live from Firestore.
class FriendProfilePage extends StatefulWidget {
  const FriendProfilePage({super.key, required this.uid});

  final String uid;

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  late final Future<UserProfile?> _profile = context
      .read<UserRepository>()
      .getProfile(widget.uid);

  @override
  Widget build(BuildContext context) {
    final me = context.read<AuthenticationBloc>().user!;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserProfile?>(
          future: _profile,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final profile = snap.data;
            if (profile == null) {
              return Column(
                children: [
                  const ChapterTopBar(title: 'Profile'),
                  Expanded(
                    child: Center(
                      child: Text(
                        'This reader could not be found.',
                        style: ChapterText.bodyMedium,
                      ),
                    ),
                  ),
                ],
              );
            }
            return _Body(profile: profile, myUid: me.uid, myName: me.displayName);
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.profile,
    required this.myUid,
    required this.myName,
  });

  final UserProfile profile;
  final String myUid;
  final String myName;

  @override
  Widget build(BuildContext context) {
    final social = context.read<SocialRepository>();
    final library = context.read<LibraryRepository>();
    final isMe = profile.uid == myUid;
    return Column(
      children: [
        ChapterTopBar(title: profile.displayName),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Center(
                child: ChapterAvatar(tone: toneFor(profile.uid), size: 88),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  profile.displayName,
                  style: ChapterText.headlineMedium,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(profile.handle, style: ChapterText.bodyMedium),
              ),
              if (profile.bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    profile.bio,
                    textAlign: TextAlign.center,
                    style: ChapterText.bodyMedium,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              StreamBuilder<List<Book>>(
                stream: library.watchBooks(profile.uid),
                builder: (context, booksSnap) {
                  final books = booksSnap.data ?? const <Book>[];
                  return StreamBuilder<Set<String>>(
                    stream: social.watchFollowers(profile.uid),
                    builder: (context, followersSnap) {
                      final followers = followersSnap.data ?? const {};
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                _Stat(value: '${books.length}', label: 'Books'),
                                _Stat(
                                  value: '${followers.length}',
                                  label: 'Followers',
                                ),
                                StreamBuilder<Set<String>>(
                                  stream: social.watchFollowing(profile.uid),
                                  builder: (context, s) => _Stat(
                                    value: '${(s.data ?? const {}).length}',
                                    label: 'Following',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (!isMe)
                            Row(
                              children: [
                                Expanded(
                                  child: ChapterButton(
                                    label: followers.contains(myUid)
                                        ? 'Following'
                                        : 'Follow',
                                    type: followers.contains(myUid)
                                        ? ChapterButtonType.tonal
                                        : ChapterButtonType.filled,
                                    onPressed: () => guarded(context, () async {
                                      if (followers.contains(myUid)) {
                                        await social.unfollow(
                                          myUid: myUid,
                                          otherUid: profile.uid,
                                        );
                                      } else {
                                        await social.follow(
                                          myUid: myUid,
                                          myName: myName,
                                          otherUid: profile.uid,
                                        );
                                      }
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ChapterButton(
                                    label: 'Message',
                                    type: ChapterButtonType.outlined,
                                    onPressed: () => context.push(
                                      '/chat/${Uri.encodeComponent(profile.uid)}',
                                      extra: profile.displayName,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 14),
                          _TopFive(books: books),
                          _Shelves(uid: profile.uid, books: books),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopFive extends StatelessWidget {
  const _TopFive({required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    final top = books.where((b) => b.topFiveRank != null).toList()
      ..sort((a, b) => a.topFiveRank!.compareTo(b.topFiveRank!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top 5', style: ChapterText.titleLarge),
        const SizedBox(height: 14),
        if (top.isEmpty)
          Text('No Top 5 yet.', style: ChapterText.bodyMedium)
        else
          Row(
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 61 / 92,
                    child: i < top.length
                        ? LayoutBuilder(
                            builder: (context, c) => BookCover(
                              color: top[i].coverColor,
                              width: c.maxWidth,
                              height: c.maxHeight,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _Shelves extends StatelessWidget {
  const _Shelves({required this.uid, required this.books});

  final String uid;
  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Shelf>>(
      stream: context.read<LibraryRepository>().watchShelves(uid),
      builder: (context, snap) {
        final shelves = snap.data ?? const <Shelf>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shelves', style: ChapterText.titleLarge),
            const SizedBox(height: 14),
            if (shelves.isEmpty)
              Text('No shelves yet.', style: ChapterText.bodyMedium)
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final s in shelves)
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 2,
                      child: ShelfCard(
                        name: s.name,
                        count: _count(books.where((b) => b.shelfId == s.id)),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  String _count(Iterable<Book> list) {
    final n = list.length;
    return '$n ${n == 1 ? 'book' : 'books'}';
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
