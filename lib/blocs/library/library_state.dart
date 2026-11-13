part of 'library_cubit.dart';

@immutable
sealed class LibraryState {
  const LibraryState();
}

/// Not signed in, or the first snapshot hasn't arrived yet.
final class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

final class LibraryError extends LibraryState {
  const LibraryError(this.message);
  final String message;
}

final class LibraryLoaded extends LibraryState {
  const LibraryLoaded({required this.shelves, required this.books});

  final List<Shelf> shelves;
  final List<Book> books;

  bool get isEmpty => books.isEmpty;

  List<Book> booksOn(String shelfId) => [
    for (final b in books)
      if (b.shelfId == shelfId) b,
  ];

  Shelf? shelfById(String id) {
    for (final s in shelves) {
      if (s.id == id) return s;
    }
    return null;
  }

  String shelfName(String? id) => shelfById(id ?? '')?.name ?? 'Unshelved';

  Book? bookById(String? id) {
    if (id == null) return null;
    for (final b in books) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Books pinned to the Top 5, in rank order.
  List<Book> get topFive => [
    for (final b in books)
      if (b.topFiveRank != null) b,
  ]..sort((a, b) => a.topFiveRank!.compareTo(b.topFiveRank!));

  /// Most recently added book on the "Currently reading" shelf.
  Book? get currentlyReading {
    final reading = booksOn(ReadingStatus.reading.shelfId);
    return reading.isEmpty ? null : reading.first;
  }
}
