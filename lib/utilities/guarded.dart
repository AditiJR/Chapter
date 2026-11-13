import 'package:flutter/material.dart';

/// Runs [action] and shows a snackbar instead of crashing if it throws.
Future<void> guarded(
  BuildContext context,
  Future<void> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
  }
}
