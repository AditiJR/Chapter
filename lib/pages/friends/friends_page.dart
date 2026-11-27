import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../model/friend.dart';
import '../../model/social.dart';
import '../../model/user_profile.dart';
import '../../navigation/my_navigator_route.dart';
import '../../repositories/social/social_repository.dart';
import '../../repositories/users/user_repository.dart';
import '../../theme/theme.dart';
import '../../utilities/guarded.dart';
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

  final _search = TextEditingController();
  StreamSubscription<Set<String>>? _followingSub;
  StreamSubscription<Set<String>>? _followersSub;

  List<UserProfile> _people = const [];
  Set<String> _following = const {};
  Set<String> _followers = const {};
  List<ActivityItem> _activity = const [];
  bool _loaded = false;
  String? _error;

  String get _myUid => context.read<AuthenticationBloc>().user!.uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    final social = context.read<SocialRepository>();
    _followingSub = social
        .watchFollowing(_myUid)
        .listen(
          (ids) {
            _following = ids;
            _loadActivity();
            if (mounted) setState(() {});
          },
          onError: (Object e) {
            if (mounted) setState(() => _error = '$e');
          },
        );
    _followersSub = social.watchFollowers(_myUid).listen((ids) {
      if (mounted) setState(() => _followers = ids);
    });
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    try {
      final people = await context.read<UserRepository>().listUsers(
        excludeUid: _myUid,
      );
      if (!mounted) return;
      setState(() {
        _people = people;
        _loaded = true;
        _error = null;
      });
      _loadActivity();
    } catch (e) {
      if (mounted) {
        setState(() {
          _loaded = true;
          _error = 'Could not load readers.\n$e';
        });
      }
    }
  }

  Future<void> _loadActivity() async {
    final names = {
      for (final p in _people)
        if (_following.contains(p.uid)) p.uid: p.displayName,
    };
    if (names.isEmpty) {
      if (mounted) setState(() => _activity = const []);
      return;
    }
    try {
      final items = await context.read<SocialRepository>().loadActivity(names);
      if (mounted) setState(() => _activity = items);
    } catch (_) {}
  }

  @override
  void dispose() {
    _followingSub?.cancel();
    _followersSub?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow(UserProfile p) {
    final me = context.read<AuthenticationBloc>().user!;
    final social = context.read<SocialRepository>();
    return guarded(context, () async {
      if (_following.contains(p.uid)) {
        await social.unfollow(myUid: me.uid, otherUid: p.uid);
      } else {
        await social.follow(
          myUid: me.uid,
          myName: me.displayName,
          otherUid: p.uid,
        );
      }
    });
  }

  void _openProfile(String uid) => context.push('/friend/$uid');

  List<UserProfile> _matching(Iterable<UserProfile> list) {
    final q = _search.text.trim().toLowerCase().replaceFirst('@', '');
    if (q.isEmpty) return list.toList();
    return [
      for (final p in list)
        if (p.displayName.toLowerCase().contains(q) ||
            p.username.toLowerCase().contains(q))
          p,
    ];
  }

  Widget _row(UserProfile p) => UserRow(
    profile: p,
    following: _following.contains(p.uid),
    onToggleFollow: () => _toggleFollow(p),
    onTap: () => _openProfile(p.uid),
  );

  Widget _empty(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: ChapterText.bodyMedium,
    ),
  );

  List<Widget> _body() {
    if (!_loaded) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [_empty(_error!)];
    }
    final searching = _search.text.trim().isNotEmpty;
    if (searching) {
      final hits = _matching(_people);
      return hits.isEmpty
          ? [_empty('No readers match "${_search.text.trim()}".')]
          : [for (final p in hits) _row(p)];
    }
    switch (_tab) {
      case 'Following':
        final list = _people.where((p) => _following.contains(p.uid));
        return list.isEmpty
            ? [_empty('You are not following anyone yet.')]
            : [for (final p in list) _row(p)];
      case 'Followers':
        final list = _people.where((p) => _followers.contains(p.uid));
        return list.isEmpty
            ? [_empty('No one follows you yet.')]
            : [for (final p in list) _row(p)];
      default:
        final suggested = _people
            .where((p) => !_following.contains(p.uid))
            .take(5);
        return [
          if (_activity.isEmpty)
            _empty(
              _following.isEmpty
                  ? 'Follow some readers to see what they are reading.'
                  : 'No recent activity from the people you follow.',
            )
          else
            for (final a in _activity) ...[
              _ActivityCard(item: a, onTap: () => _openProfile(a.uid)),
              const SizedBox(height: 14),
            ],
          if (suggested.isNotEmpty) ...[
            const SectionHeader(title: 'Suggested readers'),
            const SizedBox(height: 14),
            for (final p in suggested) ...[
              _row(p),
              const SizedBox(height: 14),
            ],
          ],
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPeople,
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
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        style: ChapterText.bodyLarge.copyWith(
                          color: ChapterColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintText: 'Find readers by name or @handle',
                          hintStyle: ChapterText.bodyMedium,
                        ),
                      ),
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
              ..._body(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item, required this.onTap});

  final ActivityItem item;
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
                  ChapterAvatar(tone: toneFor(item.uid), size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: ChapterText.labelLarge),
                        Text(timeAgo(item.at), style: ChapterText.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  BookCover(color: item.coverColor, width: 56, height: 84),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.bookTitle, style: ChapterText.titleMedium),
                        const SizedBox(height: 2),
                        Text(item.bookAuthor, style: ChapterText.bodySmall),
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
