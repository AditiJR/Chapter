import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../model/book.dart';
import '../../../repositories/books/books_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._books) : super(SearchInitial());

  final BooksRepository _books;
  int _requestId = 0;

  Future<void> search(String query) async {
    final text = query.trim();
    if (text.isEmpty) {
      clear();
      return;
    }
    // Drop out-of-order responses when the user keeps typing.
    final id = ++_requestId;
    emit(SearchLoading());
    try {
      final results = await _books.search(text);
      if (id != _requestId) return;
      emit(SearchLoaded(query: text, results: results));
    } on BooksException catch (e) {
      if (id != _requestId) return;
      emit(SearchError(message: e.message));
    } catch (e) {
      if (id != _requestId) return;
      emit(SearchError(message: 'Something went wrong. Try again.'));
    }
  }

  void clear() {
    _requestId++;
    emit(SearchInitial());
  }
}
