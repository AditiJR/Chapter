import 'dart:async';

import 'package:chapter/blocs/library/library_cubit.dart';
import 'package:chapter/model/app_user.dart';
import 'package:chapter/model/book.dart';
import 'package:chapter/model/shelf.dart';
import 'package:chapter/repositories/authentication/authentication_repository.dart';
import 'package:chapter/repositories/library/library_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuth extends AuthenticationRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  void emit(AppUser? user) => _controller.add(user);

  @override
  Stream<AppUser?> get userChanges => _controller.stream;
  @override
  AppUser? get currentUser => null;
  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      throw UnimplementedError();
  @override
  Future<AppUser> signUp({
    required String displayName,
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<void> sendPasswordReset({required String email}) async {}
  @override
  Future<void> updateDisplayName(String name) async {}

  @override
  Future<void> signOut() async {}
}

/// In-memory stand-in for Firestore.
class _FakeLibrary implements LibraryRepository {
  final _shelves = <Shelf>[];
  final _books = <Book>[];
  final _shelvesCtl = StreamController<List<Shelf>>.broadcast();
  final _booksCtl = StreamController<List<Book>>.broadcast();
  int ensureCalls = 0;

  void _push() {
    _shelvesCtl.add(List.of(_shelves));
    _booksCtl.add(List.of(_books));
  }

  @override
  Stream<List<Shelf>> watchShelves(String uid) {
    scheduleMicrotask(_push);
    return _shelvesCtl.stream;
  }

  @override
  Stream<List<Book>> watchBooks(String uid) => _booksCtl.stream;

  @override
  Future<void> ensureDefaultShelves(String uid) async {
    ensureCalls++;
    _shelves
      ..clear()
      ..addAll([
        for (var i = 0; i < ReadingStatus.values.length; i++)
          Shelf(
            id: ReadingStatus.values[i].shelfId,
            name: ReadingStatus.values[i].label,
            isDefault: true,
            order: i,
          ),
      ]);
  }

  @override
  Future<void> addBook(String uid, Book book, {required String shelfId}) async {
    _books.removeWhere((b) => b.id == book.id);
    _books.insert(0, book.copyWith(shelfId: shelfId));
    _push();
  }

  @override
  Future<void> moveBook(String uid, String bookId, String shelfId) async {
    final i = _books.indexWhere((b) => b.id == bookId);
    _books[i] = _books[i].copyWith(shelfId: shelfId);
    _push();
  }

  @override
  Future<void> setTags(String uid, String bookId, List<String> tags) async {
    final i = _books.indexWhere((b) => b.id == bookId);
    _books[i] = _books[i].copyWith(tags: tags);
    _push();
  }

  @override
  Future<void> removeBook(String uid, String bookId) async {
    _books.removeWhere((b) => b.id == bookId);
    _push();
  }

  @override
  Future<void> setTopFive(String uid, List<String> bookIds) async {
    for (var i = 0; i < _books.length; i++) {
      final rank = bookIds.indexOf(_books[i].id!);
      _books[i] = Book(
        id: _books[i].id,
        title: _books[i].title,
        author: _books[i].author,
        coverColor: _books[i].coverColor,
        status: _books[i].status,
        shelfId: _books[i].shelfId,
        topFiveRank: rank == -1 ? null : rank + 1,
      );
    }
    _push();
  }

  @override
  Future<void> createShelf(String uid, String name) async {
    _shelves.add(Shelf(id: name.toLowerCase(), name: name));
    _push();
  }

  @override
  Future<void> deleteShelf(String uid, String shelfId) async {
    for (var i = 0; i < _books.length; i++) {
      if (_books[i].shelfId == shelfId) {
        _books[i] = _books[i].copyWith(shelfId: ReadingStatus.toBeRead.shelfId);
      }
    }
    _shelves.removeWhere((s) => s.id == shelfId);
    _push();
  }
}

Book _book(String id, {String title = 'Book'}) => Book(
  id: id,
  title: '$title $id',
  author: 'Author',
  coverColor: Colors.red,
  status: ReadingStatus.toBeRead,
);

const _user = AppUser(uid: 'u1', email: 'a@b.com', displayName: 'Ada Lovelace');

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late _FakeAuth auth;
  late _FakeLibrary library;
  late LibraryCubit cubit;

  setUp(() async {
    auth = _FakeAuth();
    library = _FakeLibrary();
    cubit = LibraryCubit(library, auth);
    auth.emit(_user);
    await _settle();
  });

  tearDown(() => cubit.close());

  LibraryLoaded loaded() => cubit.state as LibraryLoaded;

  test('loads the built-in shelves for a signed-in user', () {
    expect(library.ensureCalls, 1);
    expect(loaded().shelves.map((s) => s.name), [
      'Finished',
      'Currently reading',
      'To be read',
      'DNF',
    ]);
    expect(loaded().isEmpty, isTrue);
  });

  test('adding and moving a book updates shelves', () async {
    await cubit.addBook(_book('a'), shelfId: 'reading');
    await _settle();
    expect(loaded().booksOn('reading'), hasLength(1));
    expect(loaded().currentlyReading?.id, 'a');

    await cubit.moveBook(loaded().books.first, 'finished');
    await _settle();
    expect(loaded().booksOn('reading'), isEmpty);
    expect(loaded().booksOn('finished'), hasLength(1));
    expect(loaded().shelfName('finished'), 'Finished');
  });

  test('moving a book that is not saved adds it', () async {
    await cubit.moveBook(_book('z'), 'dnf');
    await _settle();
    expect(loaded().booksOn('dnf').single.id, 'z');
  });

  test('top 5 holds at most five books', () async {
    for (final id in ['a', 'b', 'c', 'd', 'e', 'f']) {
      await cubit.addBook(_book(id), shelfId: 'toBeRead');
    }
    await _settle();

    for (final b in List.of(loaded().books).take(5)) {
      expect(await cubit.pinToTopFive(b), isTrue);
      await _settle();
    }
    expect(loaded().topFive, hasLength(5));

    final sixth = loaded().books.firstWhere((b) => b.topFiveRank == null);
    expect(await cubit.pinToTopFive(sixth), isFalse);
    expect(loaded().topFive, hasLength(5));
  });

  test('deleting a shelf keeps its books in To be read', () async {
    await cubit.createShelf('Favorites');
    await cubit.addBook(_book('a'), shelfId: 'favorites');
    await _settle();
    expect(loaded().booksOn('favorites'), hasLength(1));

    await cubit.deleteShelf('favorites');
    await _settle();
    expect(loaded().shelfById('favorites'), isNull);
    expect(loaded().booksOn('toBeRead').single.id, 'a');
  });

  test('signing out clears the library', () async {
    auth.emit(null);
    await _settle();
    expect(cubit.state, isA<LibraryLoading>());
  });
}
