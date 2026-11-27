import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/book.dart';
import '../../../repositories/books/books_repository.dart';
import '../../../theme/theme.dart';
import '../../../widgets/book_cover.dart';
import 'scan_result_sheet.dart';

/// Lets the user type a title or ISBN when the barcode will not scan.
/// Picking a result opens the same "Book found" sheet the scanner uses.
Future<void> showManualEntrySheet(BuildContext context) {
  final books = context.read<BooksRepository>();
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: ChapterColors.background,
    builder: (sheetContext) => _ManualEntrySheet(
      books: books,
      parentContext: context,
    ),
  );
}

class _ManualEntrySheet extends StatefulWidget {
  const _ManualEntrySheet({required this.books, required this.parentContext});

  final BooksRepository books;
  final BuildContext parentContext;

  @override
  State<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<_ManualEntrySheet> {
  final _field = TextEditingController();
  List<Book>? _results;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final query = _field.text.trim();
    if (query.isEmpty || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // search() recognises a 10/13-digit ISBN on its own.
      final found = await widget.books.search(query);
      if (!mounted) return;
      setState(() => _results = found);
    } on BooksException catch (e) {
      if (!mounted) return;
      setState(() {
        _results = null;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pick(Book book) async {
    final parent = widget.parentContext;
    Navigator.of(context).pop();
    if (parent.mounted) await showScanResultSheet(parent, book);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Text('Find a book', style: ChapterText.headlineMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _field,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Title, author or ISBN',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _submit,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _body(results)),
          ],
        ),
      ),
    );
  }

  Widget _body(List<Book>? results) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _message(_error!);
    }
    if (results == null) {
      return _message('Type a title or paste the ISBN printed on the cover.');
    }
    if (results.isEmpty) return _message('No books found.');
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        for (final b in results)
          ListTile(
            leading: BookCover(color: b.coverColor, width: 40, height: 58),
            title: Text(
              b.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ChapterText.titleMedium,
            ),
            subtitle: Text(b.author, style: ChapterText.bodyMedium),
            onTap: () => _pick(b),
          ),
      ],
    );
  }

  Widget _message(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: ChapterText.bodyMedium,
      ),
    ),
  );
}
