import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/book.dart';
import '../../model/shelf.dart';

/// Reads and writes one user's shelves and books.
abstract class LibraryRepository {
  Stream<List<Shelf>> watchShelves(String uid);
  Stream<List<Book>> watchBooks(String uid);

  /// Creates the four built-in shelves if they don't exist yet.
  Future<void> ensureDefaultShelves(String uid);

  /// Saves [book] on [shelfId]. If it is already saved, it is moved instead.
  Future<void> addBook(String uid, Book book, {required String shelfId});
  Future<void> moveBook(String uid, String bookId, String shelfId);
  Future<void> setTags(String uid, String bookId, List<String> tags);
  Future<void> removeBook(String uid, String bookId);

  /// Pins exactly [bookIds] (in order, max 5) as the Top 5.
  Future<void> setTopFive(String uid, List<String> bookIds);

  Future<void> createShelf(String uid, String name);

  /// Deletes a custom shelf; its books move to "To be read".
  Future<void> deleteShelf(String uid, String shelfId);
}

class FirestoreLibraryRepository implements LibraryRepository {
  FirestoreLibraryRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _shelves(String uid) =>
      _db.collection('users').doc(uid).collection('shelves');

  CollectionReference<Map<String, dynamic>> _books(String uid) =>
      _db.collection('users').doc(uid).collection('books');

  // Built-in shelves in display order.
  static const _defaultOrder = [
    ReadingStatus.reading,
    ReadingStatus.finished,
    ReadingStatus.toBeRead,
    ReadingStatus.dnf,
  ];

  @override
  Future<void> ensureDefaultShelves(String uid) async {
    final batch = _db.batch();
    for (var i = 0; i < _defaultOrder.length; i++) {
      final status = _defaultOrder[i];
      batch.set(_shelves(uid).doc(status.shelfId), {
        'name': status.label,
        'isDefault': true,
        'order': i,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Stream<List<Shelf>> watchShelves(String uid) {
    return _shelves(uid).snapshots().map((snap) {
      final shelves = [
        for (final doc in snap.docs)
          Shelf(
            id: doc.id,
            name: (doc.data()['name'] as String?) ?? 'Shelf',
            isDefault: (doc.data()['isDefault'] as bool?) ?? false,
            order:
                (doc.data()['order'] as int?) ??
                1000 +
                    (((doc.data()['createdAt'] as Timestamp?)
                                ?.millisecondsSinceEpoch ??
                            0) ~/
                        1000),
          ),
      ]..sort((a, b) => a.order.compareTo(b.order));
      return shelves;
    });
  }

  @override
  Stream<List<Book>> watchBooks(String uid) {
    return _books(uid).snapshots().map((snap) {
      final books = [for (final doc in snap.docs) _bookFromDoc(doc)];
      // Newest first. Pending writes have no server timestamp yet; treat
      // them as "now".
      books.sort(
        (a, b) => (b.addedAt ?? DateTime.now()).compareTo(
          a.addedAt ?? DateTime.now(),
        ),
      );
      return books;
    });
  }

  Book _bookFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final shelfId = (d['shelfId'] as String?) ?? ReadingStatus.toBeRead.shelfId;
    return Book(
      id: doc.id,
      isbn: d['isbn'] as String?,
      title: (d['title'] as String?) ?? 'Untitled',
      author: (d['author'] as String?) ?? 'Unknown author',
      coverColor: Color((d['coverColor'] as int?) ?? 0xff7b2d3b),
      status: ReadingStatus.fromShelfId(shelfId) ?? ReadingStatus.toBeRead,
      shelfId: shelfId,
      addedAt: (d['addedAt'] as Timestamp?)?.toDate(),
      topFiveRank: d['topFiveRank'] as int?,
      year: d['year'] as int?,
      pages: d['pages'] as int?,
      about: d['about'] as String?,
      tags: ((d['tags'] as List?) ?? const []).cast<String>(),
    );
  }

  /// Stable document id so adding the same book twice doesn't duplicate it.
  static String bookDocId(Book book) {
    final raw = book.id ?? book.isbn ?? book.title.toLowerCase();
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }

  @override
  Future<void> addBook(String uid, Book book, {required String shelfId}) async {
    final ref = _books(uid).doc(bookDocId(book));
    final existing = await ref.get();
    if (existing.exists) {
      await ref.update({'shelfId': shelfId});
      return;
    }
    await ref.set({
      'title': book.title,
      'author': book.author,
      'coverColor': book.coverColor.toARGB32(),
      'shelfId': shelfId,
      'isbn': book.isbn,
      'year': book.year,
      'pages': book.pages,
      'about': book.about,
      'tags': book.tags,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> moveBook(String uid, String bookId, String shelfId) =>
      _books(uid).doc(bookId).update({'shelfId': shelfId});

  @override
  Future<void> setTags(String uid, String bookId, List<String> tags) =>
      _books(uid).doc(bookId).update({'tags': tags});

  @override
  Future<void> removeBook(String uid, String bookId) =>
      _books(uid).doc(bookId).delete();

  @override
  Future<void> setTopFive(String uid, List<String> bookIds) async {
    final ids = bookIds.take(5).toList();
    final pinned = await _books(uid)
        .where('topFiveRank', isGreaterThan: 0)
        .get();
    final batch = _db.batch();
    for (final doc in pinned.docs) {
      if (!ids.contains(doc.id)) {
        batch.update(doc.reference, {'topFiveRank': FieldValue.delete()});
      }
    }
    for (var i = 0; i < ids.length; i++) {
      batch.update(_books(uid).doc(ids[i]), {'topFiveRank': i + 1});
    }
    await batch.commit();
  }

  @override
  Future<void> createShelf(String uid, String name) {
    return _shelves(uid).add({
      'name': name.trim(),
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteShelf(String uid, String shelfId) async {
    final books = await _books(uid).where('shelfId', isEqualTo: shelfId).get();
    final batch = _db.batch();
    for (final doc in books.docs) {
      batch.update(doc.reference, {'shelfId': ReadingStatus.toBeRead.shelfId});
    }
    batch.delete(_shelves(uid).doc(shelfId));
    await batch.commit();
  }
}
