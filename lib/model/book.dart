import 'package:flutter/material.dart';

enum ReadingStatus {
  finished("Finished"),
  reading("Currently reading"),
  toBeRead("To be read"),
  dnf("DNF");

  const ReadingStatus(this.label);
  final String label;
}

class Book {
  final String title;
  final String author;
  final Color coverColor;
  final ReadingStatus status;
  final int? year;
  final int? pages;
  final String? about;
  final List<String> tags;

  const Book({
    required this.title,
    required this.author,
    required this.coverColor,
    required this.status,
    this.year,
    this.pages,
    this.about,
    this.tags = const [],
  });
}

class Shelf {
  final String name;
  final int bookCount;

  const Shelf({required this.name, required this.bookCount});
}
