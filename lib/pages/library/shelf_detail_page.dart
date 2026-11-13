import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/library/library_cubit.dart';
import '../../navigation/book_navigation.dart';
import '../../navigation/my_navigator_route.dart';
import '../../theme/theme.dart';
import '../../utilities/guarded.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/chapter_chip.dart';
import '../../widgets/chapter_top_bar.dart';
import 'views/delete_shelf_dialog.dart';
import 'views/shelf_menu_sheet.dart';

class ShelfDetailPage extends StatefulWidget {
  const ShelfDetailPage({super.key, required this.shelfId});

  final String shelfId;

  @override
  State<ShelfDetailPage> createState() => _ShelfDetailPageState();
}

class _ShelfDetailPageState extends State<ShelfDetailPage> {
  static const _all = 'All';
  String _filter = _all;

  Future<void> _openMenu(LibraryLoaded library) async {
    final shelf = library.shelfById(widget.shelfId);
    if (shelf == null) return;
    final action = await showShelfMenuSheet(context, shelfName: shelf.name);
    if (!mounted || action != ShelfMenuAction.delete) return;

    if (shelf.isDefault) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Built-in shelves can't be deleted.")),
        );
      return;
    }

    final count = library.booksOn(shelf.id).length;
    final confirmed = await showDeleteShelfDialog(
      context,
      shelfName: shelf.name,
      bookCount: count,
    );
    if (!confirmed || !mounted) return;
    final cubit = context.read<LibraryCubit>();
    context.go(MyNavigatorRoute.library.path);
    await guarded(context, () => cubit.deleteShelf(shelf.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LibraryCubit>().state;
    if (state is! LibraryLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final shelf = state.shelfById(widget.shelfId);
    if (shelf == null) {
      // The shelf was just deleted (or the link is stale).
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const ChapterTopBar(title: 'Shelf'),
              Expanded(
                child: Center(
                  child: Text(
                    'This shelf no longer exists.',
                    style: ChapterText.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final books = state.booksOn(shelf.id);
    final tags = <String>{for (final b in books) ...b.tags}.take(5).toList();
    final filters = [_all, ...tags];
    final visible = _filter == _all
        ? books
        : [
            for (final b in books)
              if (b.tags.contains(_filter)) b,
          ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChapterTopBar(title: shelf.name, onAction: () => _openMenu(state)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text(
                    '${books.length} ${books.length == 1 ? 'book' : 'books'} · sorted by recently added',
                    style: ChapterText.bodyMedium,
                  ),
                  if (filters.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final f in filters)
                            ChapterChip(
                              label: f,
                              selected: f == _filter,
                              onTap: () => setState(() => _filter = f),
                            ),
                        ],
                      ),
                    ),
                  if (books.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          'No books on this shelf yet.',
                          style: ChapterText.bodyLarge,
                        ),
                      ),
                    ),
                  for (final book in visible)
                    BookListTile(
                      book: book,
                      badge: shelf.name,
                      onTap: () => context.openBook(book),
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
