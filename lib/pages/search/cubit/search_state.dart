part of 'search_cubit.dart';

@immutable
sealed class SearchState {}

/// Nothing searched yet (shows recent searches and popular books).
final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchLoaded extends SearchState {
  SearchLoaded({required this.query, required this.results});
  final String query;
  final List<Book> results;
}

final class SearchError extends SearchState {
  SearchError({required this.message});
  final String message;
}
