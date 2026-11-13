import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../model/book.dart';
import '../../blocs/library/library_cubit.dart';
import '../../navigation/my_navigator_route.dart';
import '../../repositories/library/library_repository.dart';
import '../../utilities/guarded.dart';
import '../../widgets/chapter_top_bar.dart';
import '../../theme/theme.dart';
import '../../widgets/book_actions.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/chapter_button.dart';
import '../../widgets/chapter_chip.dart';
import '../../widgets/chapter_dialog.dart';
import 'views/buy_sheet.dart';
import 'views/edit_tags_sheet.dart';
import 'views/move_to_shelf_sheet.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.title, this.book});

  final String title;

  /// The book to show. For books that are already saved, the live library
  /// copy (shelf, tags, ...) takes precedence.
  final Book? book;

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  /// The saved copy if the book is in the library, else the one we were given.
  Book _currentBook(LibraryState state) {
    final given = widget.book!;
    if (state is LibraryLoaded) {
      final saved = state.bookById(FirestoreLibraryRepository.bookDocId(given));
      if (saved != null) return saved;
    }
    return given;
  }

  void _toast(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ChapterColors.onSurface,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: ChapterText.bodyMedium.copyWith(
              color: ChapterColors.background,
            ),
          ),
          action: action,
        ),
      );
  }

  Future<void> _moveToShelf(Book book) async {
    final cubit = context.read<LibraryCubit>();
    final shelfId = await showMoveToShelfSheet(
      context,
      currentShelfId: book.shelfId,
    );
    if (shelfId == null || !mounted) return;
    await guarded(context, () => cubit.moveBook(book, shelfId));
    if (!mounted) return;
    final state = cubit.state;
    final name = state is LibraryLoaded ? state.shelfName(shelfId) : 'shelf';
    _toast(book.isInLibrary ? 'Moved to $name' : 'Added to $name');
  }

  Future<void> _editTags(Book book) async {
    if (!book.isInLibrary) {
      _toast('Add this book to a shelf first.');
      return;
    }
    final cubit = context.read<LibraryCubit>();
    final tags = await showEditTagsSheet(context, tags: book.tags);
    if (tags == null || !mounted) return;
    await guarded(context, () => cubit.setTags(book, tags));
  }

  Future<void> _pin(Book book) async {
    if (!book.isInLibrary) {
      _toast('Add this book to a shelf first.');
      return;
    }
    final cubit = context.read<LibraryCubit>();
    var pinned = false;
    await guarded(context, () async => pinned = await cubit.pinToTopFive(book));
    if (!mounted) return;
    if (pinned) {
      _toast(
        'Pinned to your Top 5',
        action: SnackBarAction(
          label: 'View',
          textColor: ChapterColors.primaryContainer,
          onPressed: () => context.go(MyNavigatorRoute.profile.path),
        ),
      );
    } else {
      _toast('Your Top 5 is full. Remove one first.');
    }
  }

  Future<void> _remove(Book book) async {
    if (!book.isInLibrary) {
      _toast("This book isn't in your library.");
      return;
    }
    final cubit = context.read<LibraryCubit>();
    final confirmed = await showChapterDialog<bool>(
      context,
      icon: SvgPicture.asset(
        'assets/icons/trash_large.svg',
        width: 28,
        height: 28,
      ),
      title: 'Remove “${book.title}”?',
      body: 'It will be removed from all your shelves and your top 5.',
      actions: [
        DialogAction(
          label: 'Cancel',
          onTap: () => Navigator.of(context).pop(false),
        ),
        DialogAction(
          label: 'Remove',
          filledColor: ChapterColors.error,
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed != true || !mounted) return;
    context.pop();
    await cubit.removeBook(book);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.book == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const ChapterTopBar(title: 'Book'),
              Expanded(
                child: Center(
                  child: Text('Book not found.', style: ChapterText.bodyLarge),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final state = context.watch<LibraryCubit>().state;
    final book = _currentBook(state);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        'assets/icons/arrow_left.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      'assets/icons/more.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: BookCover(
                        color: book.coverColor,
                        title: book.title,
                        author: book.author,
                        width: 132,
                        height: 198,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        book.title,
                        textAlign: TextAlign.center,
                        style: ChapterText.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        [
                          book.author,
                          if (book.pages != null) '${book.pages} pages',
                        ].join(' · '),
                        textAlign: TextAlign.center,
                        style: ChapterText.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 14),
                    BookActions(
                      onShelf: () => _moveToShelf(book),
                      onTags: () => _editTags(book),
                      onPin: () => _pin(book),
                      onRemove: () => _remove(book),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in book.tags)
                          ChapterChip(label: tag, selected: true),
                      ],
                    ),
                    if (book.about != null) ...[
                      const SizedBox(height: 14),
                      Text('About', style: ChapterText.titleLarge),
                      const SizedBox(height: 14),
                      Text(book.about!, style: ChapterText.bodyMedium),
                    ],
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  ChapterButton(
                    label: 'Buy this book',
                    onPressed: () => showBuySheet(context, book),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Opens Bookshop.org or Amazon. Chapter may earn a commission.',
                    textAlign: TextAlign.center,
                    style: ChapterText.labelSmall.copyWith(
                      color: ChapterColors.onSurfaceVariant,
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
