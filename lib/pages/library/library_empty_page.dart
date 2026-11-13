import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/authentication/authentication_bloc.dart';

import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../widgets/chapter_button.dart';

class LibraryEmptyPage extends StatelessWidget {
  const LibraryEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${context.read<AuthenticationBloc>().user?.firstName ?? ''}',
                      style: ChapterText.bodyMedium,
                    ),
                    Text('Your library', style: ChapterText.headlineMedium),
                  ],
                ),
              ),
              const SizedBox(height: 46),
              const _EmptyShelfIllustration(),
              const SizedBox(height: 16),
              Text(
                'Your shelves are empty',
                textAlign: TextAlign.center,
                style: ChapterText.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Scan the barcode on any book to add it, or search by title.',
                textAlign: TextAlign.center,
                style: ChapterText.bodyLarge,
              ),
              const Spacer(),
              ChapterButton(
                label: 'Scan your first book',
                onPressed: () => context.go(MyNavigatorRoute.scan.path),
              ),
              const SizedBox(height: 16),
              ChapterButton(
                label: 'Search by title',
                type: ChapterButtonType.outlined,
                onPressed: () => context.go(MyNavigatorRoute.search.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyShelfIllustration extends StatelessWidget {
  const _EmptyShelfIllustration();

  Widget _plank(double top) => Positioned(
    left: 30,
    top: top,
    child: Container(
      width: 200,
      height: 8,
      decoration: BoxDecoration(
        color: ChapterColors.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );

  Widget _book(double left, double width, Color color) => Positioned(
    left: left,
    top: 16,
    child: Container(
      width: width,
      height: 54,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 190,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: ChapterColors.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          _plank(70),
          _plank(140),
          _book(54, 38, ChapterColors.primary),
          _book(90, 28, ChapterColors.tertiary),
        ],
      ),
    );
  }
}
