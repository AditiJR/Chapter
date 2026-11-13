import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../blocs/library/library_cubit.dart';
import '../../navigation/book_navigation.dart';

import '../../navigation/my_navigator_route.dart';
import '../../model/book.dart';
import '../../theme/theme.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/section_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthenticationBloc>().user;
    final library = context.watch<LibraryCubit>().state;
    final books = library is LibraryLoaded ? library.books.length : 0;
    final topFive = library is LibraryLoaded ? library.topFive : const <Book>[];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Profile', style: ChapterText.headlineMedium),
                ),
                CircleIconButton(
                  icon: 'assets/icons/settings.svg',
                  onTap: () => context.push(MyNavigatorRoute.settings.path),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: ChapterColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  user?.initial ?? '?',
                  style: ChapterText.lora(
                    26,
                    34,
                    FontWeight.w600,
                    color: ChapterColors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                user?.firstName ?? '',
                style: ChapterText.headlineMedium,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${user?.handle ?? ''} · reading since Oct 2026',
                style: ChapterText.bodyMedium,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  _Stat(value: '$books', label: 'Books'),
                  const _Stat(value: '0', label: 'Followers'),
                  const _Stat(value: '0', label: 'Following'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ChapterButton(
              label: 'Edit profile',
              type: ChapterButtonType.tonal,
              onPressed: () => context.push(MyNavigatorRoute.editProfile.path),
            ),
            const SizedBox(height: 14),
            SectionHeader(
              title: 'Top 5',
              action: 'Edit',
              onAction: () => context.push(MyNavigatorRoute.editTopFive.path),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 61 / 92,
                      child: i < topFive.length
                          ? GestureDetector(
                              onTap: () => context.openBook(topFive[i]),
                              child: LayoutBuilder(
                                builder: (context, c) => BookCover(
                                  color: topFive[i].coverColor,
                                  width: c.maxWidth,
                                  height: c.maxHeight,
                                ),
                              ),
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ChapterColors.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ChapterColors.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/crown_banner.svg',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chapter Premium',
                          style: ChapterText.titleMedium.copyWith(
                            color: ChapterColors.onTertiaryContainer,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Custom shelf covers, advanced filters, no ads',
                          style: ChapterText.bodySmall.copyWith(
                            color: ChapterColors.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Material(
                    color: ChapterColors.tertiary,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => context.push(MyNavigatorRoute.premium.path),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Text(
                          'Upgrade',
                          style: ChapterText.labelLarge.copyWith(
                            color: ChapterColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
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
