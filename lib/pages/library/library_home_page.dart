import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../blocs/library/library_cubit.dart';
import '../../model/book.dart';
import '../../navigation/book_navigation.dart';
import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../utilities/guarded.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/push_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shelf_card.dart';
import 'library_empty_page.dart';
import 'views/new_shelf_sheet.dart';

class LibraryHomePage extends StatefulWidget {
  const LibraryHomePage({super.key});

  @override
  State<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends State<LibraryHomePage> {
  /// The demo push notification is shown once per app session.
  static bool _bannerShown = false;

  @override
  void initState() {
    super.initState();
    if (_bannerShown) return;
    _bannerShown = true;
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      showPushBanner(
        context,
        sender: 'Maya Chen',
        message: 'Did you finish Piranesi yet?',
        onTap: () => context.push('/chat/Maya%20Chen'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LibraryCubit>().state;
    return switch (state) {
      LibraryLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      LibraryError(:final message) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: ChapterText.bodyLarge,
              ),
            ),
          ),
        ),
      ),
      LibraryLoaded() when state.isEmpty => const LibraryEmptyPage(),
      LibraryLoaded() => _buildLoaded(context, state),
    };
  }

  Widget _buildLoaded(BuildContext context, LibraryLoaded library) {
    final name = context.read<AuthenticationBloc>().user?.firstName ?? '';
    final reading = library.currentlyReading;
    final shelves = library.shelves;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good evening, $name',
                            style: ChapterText.bodyMedium,
                          ),
                          Text(
                            'Your library',
                            style: ChapterText.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    CircleIconButton(
                      icon: 'assets/icons/bell.svg',
                      onTap: () =>
                          context.push(MyNavigatorRoute.notifications.path),
                    ),
                  ],
                ),
                if (reading != null) ...[
                  const SizedBox(height: 18),
                  _CurrentlyReadingCard(
                    book: reading,
                    onTap: () => context.openBook(reading),
                  ),
                ],
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Shelves',
                  action: 'New shelf',
                  onAction: () async {
                    final cubit = context.read<LibraryCubit>();
                    final shelfName = await showNewShelfSheet(context);
                    if (shelfName == null || shelfName.isEmpty) return;
                    if (!context.mounted) return;
                    await guarded(context, () => cubit.createShelf(shelfName));
                  },
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < shelves.length; i += 2) ...[
                  Row(
                    children: [
                      for (var j = i; j < i + 2; j++) ...[
                        if (j > i) const SizedBox(width: 12),
                        Expanded(
                          child: j < shelves.length
                              ? ShelfCard(
                                  name: shelves[j].name,
                                  count: _countLabel(
                                    library.booksOn(shelves[j].id).length,
                                  ),
                                  onTap: () => context.go(
                                    '${MyNavigatorRoute.library.path}/shelf/${Uri.encodeComponent(shelves[j].id)}',
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
                const SectionHeader(title: 'Recently added'),
                const SizedBox(height: 18),
                for (final book in library.books.take(3))
                  BookListTile(
                    book: book,
                    badge: library.shelfName(book.shelfId),
                    onTap: () => context.openBook(book),
                  ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Material(
                color: ChapterColors.primaryContainer,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.go(MyNavigatorRoute.scan.path),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 20, 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/scan_fab.svg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Scan book',
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

  static String _countLabel(int n) => '$n ${n == 1 ? 'book' : 'books'}';
}

/// "Gabrielle Zevin" -> "G. Zevin".
String shortAuthor(String author) {
  final parts = author.split(',').first.trim().split(' ');
  if (parts.length < 2) return author;
  return '${parts.first[0]}. ${parts.last}';
}

class _CurrentlyReadingCard extends StatelessWidget {
  const _CurrentlyReadingCard({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChapterColors.surfaceContainer,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              BookCover(
                color: book.coverColor,
                title: book.title,
                author: shortAuthor(book.author),
                width: 88,
                height: 132,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENTLY READING',
                      style: ChapterText.labelSmall.copyWith(
                        color: ChapterColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: ChapterText.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(book.author, style: ChapterText.bodyMedium),
                    const SizedBox(height: 6),
                    Text(
                      'In your library',
                      style: ChapterText.labelMedium.copyWith(
                        color: ChapterColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
