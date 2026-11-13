import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/book_list_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _recent = [...mockRecentSearches];
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value.trim());
  }

  void _openBook(String title) =>
      context.push('/book/${Uri.encodeComponent(title)}');

  @override
  Widget build(BuildContext context) {
    final searching = _query.isNotEmpty;
    // De-duplicate titles shown in the catalog.
    final results = [
      for (final b in mockCatalog)
        if (b.title.toLowerCase().contains(_query.toLowerCase()) ||
            b.author.toLowerCase().contains(_query.toLowerCase()))
          b,
    ];
    final seen = <String>{};
    final unique = [
      for (final b in results)
        if (seen.add(b.title)) b,
    ];

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
              onChanged: (v) => setState(() => _query = v.trim()),
              onScan: () => context.go(MyNavigatorRoute.scan.path),
            ),
            const SizedBox(height: 14),
            if (searching) ...[
              Text(
                '${unique.length} result${unique.length == 1 ? '' : 's'}',
                style: ChapterText.bodyMedium,
              ),
              const SizedBox(height: 10),
              for (final book in unique)
                BookListTile(
                  book: book,
                  badge: book.year?.toString(),
                  onTap: () => _openBook(book.title),
                ),
            ] else ...[
              Text(
                'Recent searches',
                style: ChapterText.titleMedium.copyWith(
                  color: ChapterColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              for (final term in List.of(_recent))
                InkWell(
                  onTap: () => _search(term),
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
                          onTap: () => setState(() => _recent.remove(term)),
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
                      onTap: () => _openBook(mockPopularBooks[i].$1.title),
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
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onScan,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
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
