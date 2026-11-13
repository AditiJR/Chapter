import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../model/book.dart';
import '../../navigation/my_navigator_route.dart';
import '../../repositories/books/books_repository.dart';
import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_list_tile.dart';
import 'cubit/search_cubit.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(context.read<BooksRepository>()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  final _recent = [...mockRecentSearches];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<SearchCubit>().clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      context.read<SearchCubit>().search(value);
    });
  }

  void _searchFor(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    _debounce?.cancel();
    context.read<SearchCubit>().search(value);
  }

  void _remember(String query) {
    _recent
      ..remove(query)
      ..insert(0, query);
    if (_recent.length > 5) _recent.removeLast();
  }

  void _openBook(Book book) =>
      context.push('/book/${Uri.encodeComponent(book.title)}', extra: book);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SearchCubit>().state;
    final searching = state is! SearchInitial;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            if (!searching) ...[
              Text('Search', style: ChapterText.headlineMedium),
              const SizedBox(height: 14),
            ],
            _SearchBar(
              controller: _controller,
              onChanged: _onChanged,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) _remember(value.trim());
                _debounce?.cancel();
                context.read<SearchCubit>().search(value);
              },
              onScan: () => context.go(MyNavigatorRoute.scan.path),
            ),
            const SizedBox(height: 14),
            switch (state) {
              SearchInitial() => _Discover(
                recent: _recent,
                onTapRecent: _searchFor,
                onRemoveRecent: (t) => setState(() => _recent.remove(t)),
                onTapBook: _searchFor,
              ),
              SearchLoading() => const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              SearchError(:final message) => _Message(
                text: message,
                actionLabel: 'Try again',
                onAction: () =>
                    context.read<SearchCubit>().search(_controller.text),
              ),
              SearchLoaded(:final results) when results.isEmpty =>
                const _Message(
                  text: 'No books found. Try another title, author or ISBN.',
                ),
              SearchLoaded(:final results) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${results.length} result${results.length == 1 ? '' : 's'}',
                    style: ChapterText.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  for (final book in results)
                    BookListTile(
                      book: book,
                      badge: book.year?.toString() ?? book.status.label,
                      onTap: () => _openBook(book),
                    ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _Discover extends StatelessWidget {
  const _Discover({
    required this.recent,
    required this.onTapRecent,
    required this.onRemoveRecent,
    required this.onTapBook,
  });

  final List<String> recent;
  final ValueChanged<String> onTapRecent;
  final ValueChanged<String> onRemoveRecent;
  final ValueChanged<String> onTapBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recent.isNotEmpty) ...[
          Text(
            'Recent searches',
            style: ChapterText.titleMedium.copyWith(
              color: ChapterColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          for (final term in List.of(recent))
            InkWell(
              onTap: () => onTapRecent(term),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/search_recent.svg',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        term,
                        style: ChapterText.bodyLarge.copyWith(
                          color: ChapterColors.onSurface,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onRemoveRecent(term),
                      child: SvgPicture.asset(
                        'assets/icons/x_recent.svg',
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
        ],
        Text(
          'Popular with readers',
          style: ChapterText.titleMedium.copyWith(
            color: ChapterColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < mockPopularBooks.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onTapBook(mockPopularBooks[i].$1.title),
                child: BookCover(
                  color: mockPopularBooks[i].$1.coverColor,
                  title: mockPopularBooks[i].$2,
                  author: mockPopularBooks[i].$3,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: ChapterText.bodyLarge),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: ChapterText.labelLarge.copyWith(
                  color: ChapterColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onScan,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ChapterColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/search_bar.svg',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: ChapterText.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Title, author or ISBN',
                hintStyle: ChapterText.bodyLarge,
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onScan,
            child: SvgPicture.asset(
              'assets/icons/scan_bar.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}
