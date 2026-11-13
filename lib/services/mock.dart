import 'package:flutter/material.dart';

import '../model/book.dart';
import '../model/friend.dart';

// Shelves, books and the Top 5 now come from Firestore (see
// repositories/library). What remains here is placeholder content for
// features that are not backed by a database yet.

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
