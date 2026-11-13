import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/my_navigator_route.dart';
import '../../services/mock.dart';
import '../../theme/theme.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/chapter_chip.dart';
import '../../widgets/chapter_top_bar.dart';
import 'views/delete_shelf_dialog.dart';
import 'views/shelf_menu_sheet.dart';

class ShelfDetailPage extends StatefulWidget {
  const ShelfDetailPage({super.key, required this.shelfName});

  final String shelfName;

  @override
  State<ShelfDetailPage> createState() => _ShelfDetailPageState();
}

class _ShelfDetailPageState extends State<ShelfDetailPage> {
  static const _filters = ['All', 'Fiction', 'Sci-fi', 'Literary'];
  String _filter = 'All';

  Future<void> _openMenu() async {
    final action = await showShelfMenuSheet(
      context,
      shelfName: widget.shelfName,
    );
    if (!mounted || action != ShelfMenuAction.delete) return;
    final confirmed = await showDeleteShelfDialog(
      context,
      shelfName: widget.shelfName,
      bookCount: mockShelfBooks.length * 2,
    );
    if (confirmed && mounted) context.go(MyNavigatorRoute.library.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChapterTopBar(title: widget.shelfName, onAction: _openMenu),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text(
                    '${mockShelfBooks.length * 2} books · sorted by recently added',
                    style: ChapterText.bodyMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (final f in _filters)
                          ChapterChip(
                            label: f,
                            selected: f == _filter,
                            onTap: () => setState(() => _filter = f),
                          ),
                      ],
                    ),
                  ),
                  for (final book in mockShelfBooks)
                    BookListTile(
                      book: book,
                      onTap: () => context.push(
                        '/book/${Uri.encodeComponent(book.title)}',
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
