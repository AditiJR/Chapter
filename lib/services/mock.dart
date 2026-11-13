import 'package:flutter/material.dart';

import '../model/book.dart';
import '../model/friend.dart';

const mockShelves = [
  Shelf(name: "Currently reading", bookCount: 3),
  Shelf(name: "Finished", bookCount: 12),
  Shelf(name: "To be read", bookCount: 27),
  Shelf(name: "DNF", bookCount: 4),
];

const mockBooks = [
  Book(
    title: "Piranesi",
    author: "Susanna Clarke",
    coverColor: Color(0xff3d5a40),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Project Hail Mary",
    author: "Andy Weir",
    coverColor: Color(0xff2f4858),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Circe",
    author: "Madeline Miller",
    coverColor: Color(0xff8a4f2a),
    status: ReadingStatus.toBeRead,
  ),
];

const currentlyReading = Book(
  title: "Tomorrow, and Tomorrow, and Tomorrow",
  author: "Gabrielle Zevin",
  coverColor: Color(0xff7b2d3b),
  status: ReadingStatus.reading,
);

/// Books shown on a shelf detail page.
const mockShelfBooks = [
  Book(
    title: "The Midnight Library",
    author: "Matt Haig",
    coverColor: Color(0xff7b2d3b),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Piranesi",
    author: "Susanna Clarke",
    coverColor: Color(0xff3d5a40),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Project Hail Mary",
    author: "Andy Weir",
    coverColor: Color(0xff2f4858),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Circe",
    author: "Madeline Miller",
    coverColor: Color(0xff8a4f2a),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Klara and the Sun",
    author: "Kazuo Ishiguro",
    coverColor: Color(0xff6b5e2f),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Normal People",
    author: "Sally Rooney",
    coverColor: Color(0xff4a3f6b),
    status: ReadingStatus.finished,
  ),
];

const piranesi = Book(
  title: "Piranesi",
  author: "Susanna Clarke",
  coverColor: Color(0xff3d5a40),
  status: ReadingStatus.finished,
  year: 2020,
  pages: 272,
  about: "Piranesi lives in the House, a labyrinth of endless halls and statues. His notebooks record the tides, the birds, and the Other. Until a message appears that should not exist.",
  tags: ["Literary fantasy", "Mystery", "Read 2025"],
);

const mockRecentSearches = ["Piranesi", "Susanna Clarke", "fantasy standalone"];

/// Covers in "Popular with readers" (title shortened as on the cover).
const mockPopularBooks = [
  (
    Book(
      title: "Tomorrow, and Tomorrow, and Tomorrow",
      author: "Gabrielle Zevin",
      coverColor: Color(0xff7b2d3b),
      status: ReadingStatus.reading,
    ),
    "Tomorrow…",
    "G. Zevin",
  ),
  (
    Book(
      title: "Project Hail Mary",
      author: "Andy Weir",
      coverColor: Color(0xff2f4858),
      status: ReadingStatus.finished,
    ),
    "Project Hail Mary",
    "A. Weir",
  ),
  (
    Book(
      title: "Circe",
      author: "Madeline Miller",
      coverColor: Color(0xff8a4f2a),
      status: ReadingStatus.toBeRead,
    ),
    "Circe",
    "M. Miller",
  ),
];

/// Everything the search screen can find.
const mockCatalog = [
  piranesi,
  Book(
    title: "Piranesi (Audiobook)",
    author: "Susanna Clarke",
    coverColor: Color(0xff4a6b4d),
    status: ReadingStatus.finished,
    year: 2020,
  ),
  Book(
    title: "Piranesi: Reader's Guide",
    author: "Bloomsbury",
    coverColor: Color(0xff6b5e2f),
    status: ReadingStatus.finished,
    year: 2021,
  ),
  currentlyReading,
  ...mockBooks,
  ...mockShelfBooks,
];

/// Finds a catalog book by title, falling back to Piranesi.
Book findBook(String title) =>
    mockCatalog.firstWhere((b) => b.title == title, orElse: () => piranesi);

const mockMaya = Friend(
  name: "Maya Chen",
  handle: "maya",
  books: 142,
  tone: AvatarTone.yellow,
);
const mockJordan = Friend(
  name: "Jordan Lee",
  handle: "jordan",
  books: 64,
  tone: AvatarTone.peach,
);
const mockPriya = Friend(
  name: "Priya Nair",
  handle: "priya",
  books: 211,
  tone: AvatarTone.pink,
);
const mockSam = Friend(
  name: "Sam Ortiz",
  handle: "samreads",
  books: 96,
  tone: AvatarTone.yellow,
);

const mockFriends = [mockMaya, mockJordan, mockPriya, mockSam];

Friend findFriend(String name) =>
    mockFriends.firstWhere((f) => f.name == name, orElse: () => mockMaya);

/// Colors of the signed-in user's pinned Top 5 covers.
const topFiveColors = [
  Color(0xff3d5a40),
  Color(0xff8a4f2a),
  Color(0xff2f4858),
  Color(0xff6b5e2f),
  Color(0xff4a3f6b),
];

/// Books on the user's Top 5 list (edit screen).
const mockTopFive = [
  Book(
    title: "Piranesi",
    author: "Susanna Clarke",
    coverColor: Color(0xff3d5a40),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Circe",
    author: "Madeline Miller",
    coverColor: Color(0xff8a4f2a),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Project Hail Mary",
    author: "Andy Weir",
    coverColor: Color(0xff2f4858),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "Klara and the Sun",
    author: "Kazuo Ishiguro",
    coverColor: Color(0xff6b5e2f),
    status: ReadingStatus.finished,
  ),
];

/// Library books that can be added to the Top 5.
const mockTopFiveCandidates = [
  Book(
    title: "Normal People",
    author: "Sally Rooney",
    coverColor: Color(0xff4a3f6b),
    status: ReadingStatus.finished,
  ),
  Book(
    title: "The Midnight Library",
    author: "Matt Haig",
    coverColor: Color(0xff7a5649),
    status: ReadingStatus.finished,
  ),
];
