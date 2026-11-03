enum AvatarTone { yellow, peach, pink }

class Friend {
  final String name;
  final String handle;
  final int books;
  final AvatarTone tone;

  const Friend({
    required this.name,
    required this.handle,
    required this.books,
    required this.tone,
  });

  String get summary => '@$handle · $books books';
}
