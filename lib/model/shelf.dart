class Shelf {
  final String id;
  final String name;

  /// Built-in shelves can't be deleted.
  final bool isDefault;

  /// Sort key: built-in shelves first (in fixed order), then by creation time.
  final int order;

  const Shelf({
    required this.id,
    required this.name,
    this.isDefault = false,
    this.order = 1000,
  });
}
