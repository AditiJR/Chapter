import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../model/book.dart';

extension BookNavigation on BuildContext {
  /// Opens the details screen for [book].
  void openBook(Book book) =>
      push('/book/${Uri.encodeComponent(book.title)}', extra: book);
}
