import 'package:flutter/material.dart';

/// The four built-in shelves. [name] doubles as the shelf id in Firestore.
enum ReadingStatus {
  finished("Finished"),
  reading("Currently reading"),
  toBeRead("To be read"),
  dnf("DNF");

  const ReadingStatus(this.label);
  final String label;

  /// Shelf id used in Firestore for this built-in shelf.
  String get shelfId => name;

  static ReadingStatus? fromShelfId(String id) {
    for (final s in values) {
      if (s.name == id) return s;
    }
    return null;
  }
}

class Book {
  final String? id;
  final String? isbn;
  final String title;
  final String author;
  final Color coverColor;
  final ReadingStatus status;

  /// Shelf the book is on. Null for books that are not in the library.
  final String? shelfId;
  final DateTime? addedAt;

  /// 1..5 when pinned to the user's Top 5, otherwise null.
  final int? topFiveRank;
  final int? year;
  final int? pages;
  final String? about;
  final List<String> tags;

  const Book({
    this.id,
    this.isbn,
    required this.title,
    required this.author,
    required this.coverColor,
    required this.status,
    this.shelfId,
    this.addedAt,
    this.topFiveRank,
    this.year,
    this.pages,
    this.about,
    this.tags = const [],
  });

  /// True once the book has been saved to the user's library.
  bool get isInLibrary => shelfId != null;

  Book copyWith({
    String? shelfId,
    ReadingStatus? status,
    List<String>? tags,
    int? topFiveRank,
  }) {
    return Book(
      id: id,
      isbn: isbn,
      title: title,
      author: author,
      coverColor: coverColor,
      status: status ?? this.status,
      shelfId: shelfId ?? this.shelfId,
      addedAt: addedAt,
      topFiveRank: topFiveRank ?? this.topFiveRank,
      year: year,
      pages: pages,
      about: about,
      tags: tags ?? this.tags,
    );
  }
}
