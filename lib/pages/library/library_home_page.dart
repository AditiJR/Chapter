import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';

import '../../navigation/my_navigator_route.dart';

import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/push_banner.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shelf_card.dart';
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
                            'Good evening, ${context.read<AuthenticationBloc>().user?.firstName ?? ''}',
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
                const SizedBox(height: 18),
                const _CurrentlyReadingCard(),
                const SizedBox(height: 18),
                SectionHeader(
                  title: 'Shelves',
                  action: 'New shelf',
                  onAction: () => showNewShelfSheet(context),
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < mockShelves.length; i += 2) ...[
                  Row(
                    children: [
                      for (var j = i; j < i + 2; j++) ...[
                        if (j > i) const SizedBox(width: 12),
                        Expanded(
                          child: ShelfCard(
                            name: mockShelves[j].name,
                            count: '${mockShelves[j].bookCount} books',
                            onTap: () => context.go(
                              '${MyNavigatorRoute.library.path}/shelf/${Uri.encodeComponent(mockShelves[j].name)}',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
                const SectionHeader(title: 'Recently added'),
                const SizedBox(height: 18),
                for (final book in mockBooks)
                  BookListTile(
                    book: book,
                    onTap: () => context.push(
                      '/book/${Uri.encodeComponent(book.title)}',
                    ),
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
}

class _CurrentlyReadingCard extends StatelessWidget {
  const _CurrentlyReadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChapterColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          BookCover(
            color: currentlyReading.coverColor,
            title: currentlyReading.title,
            author: 'G. Zevin',
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
                Text(currentlyReading.title, style: ChapterText.titleLarge),
                const SizedBox(height: 6),
                Text(currentlyReading.author, style: ChapterText.bodyMedium),
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
    );
  }
}
