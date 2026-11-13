import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/secrets.dart';
import '../../model/book.dart';

/// Thrown for lookup failures with a message that is safe to show.
class BooksException implements Exception {
  BooksException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class BooksRepository {
  /// Free-text search; a 10/13-digit ISBN is detected automatically.
  Future<List<Book>> search(String query);

  /// Exact ISBN lookup (used by the barcode scanner). Null if not found.
  Future<Book?> findByIsbn(String isbn);
}

class GoogleBooksRepository implements BooksRepository {
  GoogleBooksRepository({http.Client? client, this.apiKey = googleBooksApiKey})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String apiKey;

  static const _coverPalette = [
    Color(0xff7b2d3b),
    Color(0xff3d5a40),
    Color(0xff2f4858),
    Color(0xff8a4f2a),
    Color(0xff6b5e2f),
    Color(0xff4a3f6b),
    Color(0xff7a5649),
  ];

  /// Returns the digits of [text] if it looks like an ISBN-10/13, else null.
  static String? asIsbn(String text) {
    final digits = text.replaceAll(RegExp(r'[\s-]'), '');
    final ok = RegExp(r'^(\d{13}|\d{9}[\dXx])$').hasMatch(digits);
    return ok ? digits.toUpperCase() : null;
  }

  @override
  Future<List<Book>> search(String query) async {
    final text = query.trim();
    if (text.isEmpty) return [];
    final isbn = asIsbn(text);
    return _query(isbn != null ? 'isbn:$isbn' : text);
  }

  @override
  Future<Book?> findByIsbn(String isbn) async {
    final digits = asIsbn(isbn);
    if (digits == null) throw BooksException('That is not a valid ISBN.');
    final results = await _query('isbn:$digits', maxResults: 1);
    return results.isEmpty ? null : results.first;
  }

  Future<List<Book>> _query(String q, {int maxResults = 20}) async {
    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': q,
      'maxResults': '$maxResults',
      'printType': 'books',
      if (apiKey.isNotEmpty) 'key': apiKey,
    });

    http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw BooksException('The book search timed out. Try again.');
    } catch (_) {
      throw BooksException('Network error. Check your connection.');
    }

    if (response.statusCode == 429) {
      throw BooksException(
        apiKey.isEmpty
            ? 'Book search needs a Google Books API key (see README).'
            : 'Book search quota reached. Try again later.',
      );
    }
    if (response.statusCode == 400 || response.statusCode == 403) {
      throw BooksException(
        'Google Books rejected the request. Check the API key and that the Books API is enabled.',
      );
    }
    if (response.statusCode != 200) {
      throw BooksException('Book search failed (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (body['items'] as List?) ?? const [];
    return [
      for (final item in items) ?_fromVolume(item as Map<String, dynamic>),
    ];
  }

  Book? _fromVolume(Map<String, dynamic> volume) {
    final info = volume['volumeInfo'] as Map<String, dynamic>?;
    final title = info?['title'] as String?;
    if (info == null || title == null || title.trim().isEmpty) return null;

    final id = volume['id'] as String?;
    final authors = (info['authors'] as List?)?.cast<String>() ?? const [];
    final published = info['publishedDate'] as String?;
    final identifiers = (info['industryIdentifiers'] as List?) ?? const [];

    String? isbn;
    for (final type in const ['ISBN_13', 'ISBN_10']) {
      for (final i in identifiers) {
        if (i is Map && i['type'] == type) {
          isbn = i['identifier'] as String?;
          break;
        }
      }
      if (isbn != null) break;
    }

    final categories =
        (info['categories'] as List?)?.cast<String>() ?? const [];
    final tags = <String>{
      for (final c in categories) ...c.split('/').map((e) => e.trim()),
    }.where((t) => t.isNotEmpty).take(3).toList();

    return Book(
      id: id,
      isbn: isbn,
      title: title.trim(),
      author: authors.isEmpty ? 'Unknown author' : authors.join(', '),
      coverColor:
          _coverPalette[(id ?? title).hashCode.abs() % _coverPalette.length],
      status: ReadingStatus.toBeRead,
      year: (published != null && published.length >= 4)
          ? int.tryParse(published.substring(0, 4))
          : null,
      pages: info['pageCount'] as int?,
      about: _stripHtml(info['description'] as String?),
      tags: tags,
    );
  }

  static String? _stripHtml(String? html) {
    if (html == null) return null;
    final text = html
        .replaceAll(RegExp(r'<br\s*/?>|</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    return text.isEmpty ? null : text;
  }
}
