import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../model/app_user.dart';
import '../../model/book.dart';
import '../../model/shelf.dart';
import '../../repositories/authentication/authentication_repository.dart';
import '../../repositories/library/library_repository.dart';

part 'library_state.dart';

/// Holds the signed-in user's shelves and books and live-updates from
/// Firestore. Starts and stops listening as the user signs in and out.
class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._library, AuthenticationRepository auth)
    : super(const LibraryLoading()) {
    _authSub = auth.userChanges.listen(_onUser);
  }

  final LibraryRepository _library;
  late final StreamSubscription _authSub;
  StreamSubscription<List<Shelf>>? _shelvesSub;
  StreamSubscription<List<Book>>? _booksSub;

  String? _uid;
  List<Shelf>? _shelves;
  List<Book>? _books;

  String get _requireUid {
    final uid = _uid;
    if (uid == null) throw StateError('Not signed in');
    return uid;
  }

  Future<void> _onUser(AppUser? user) async {
    await _stop();
    if (user == null) {
      emit(const LibraryLoading());
      return;
    }
    _uid = user.uid;
    emit(const LibraryLoading());
    try {
      await _library.ensureDefaultShelves(user.uid);
    } catch (e) {
      emit(LibraryError('Could not set up your library: $e'));
      return;
    }
    _shelvesSub = _library.watchShelves(user.uid).listen((s) {
      _shelves = s;
      _emitIfReady();
    }, onError: (Object e) => emit(LibraryError('$e')));
    _booksSub = _library.watchBooks(user.uid).listen((b) {
      _books = b;
      _emitIfReady();
    }, onError: (Object e) => emit(LibraryError('$e')));
  }

  void _emitIfReady() {
    final shelves = _shelves;
    final books = _books;
    if (shelves == null || books == null) return;
    emit(LibraryLoaded(shelves: shelves, books: books));
  }

  Future<void> _stop() async {
    await _shelvesSub?.cancel();
    await _booksSub?.cancel();
    _shelvesSub = null;
    _booksSub = null;
    _shelves = null;
    _books = null;
    _uid = null;
  }

  // ---- actions -----------------------------------------------------------

  /// Saves [book] on [shelfId] (moves it if it's already in the library).
  Future<void> addBook(Book book, {required String shelfId}) =>
      _library.addBook(_requireUid, book, shelfId: shelfId);

  Future<void> moveBook(Book book, String shelfId) {
    if (!book.isInLibrary) return addBook(book, shelfId: shelfId);
    return _library.moveBook(_requireUid, book.id!, shelfId);
  }

  Future<void> setTags(Book book, List<String> tags) =>
      _library.setTags(_requireUid, book.id!, tags);

  Future<void> removeBook(Book book) =>
      _library.removeBook(_requireUid, book.id!);

  Future<void> setTopFive(List<String> bookIds) =>
      _library.setTopFive(_requireUid, bookIds);

  /// Pins [book] to the Top 5 if there's room. Returns false when full.
  Future<bool> pinToTopFive(Book book) async {
    final s = state;
    if (s is! LibraryLoaded || !book.isInLibrary) return false;
    final ids = [for (final b in s.topFive) b.id!];
    if (ids.contains(book.id)) return true;
    if (ids.length >= 5) return false;
    await setTopFive([...ids, book.id!]);
    return true;
  }

  Future<void> createShelf(String name) =>
      _library.createShelf(_requireUid, name);

  Future<void> deleteShelf(String shelfId) =>
      _library.deleteShelf(_requireUid, shelfId);

  @override
  Future<void> close() async {
    await _authSub.cancel();
    await _stop();
    return super.close();
  }
}
