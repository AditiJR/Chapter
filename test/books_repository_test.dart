import 'dart:convert';

import 'package:chapter/repositories/books/books_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _sampleBody = {
  'totalItems': 2,
  'items': [
    {
      'id': 'abc123',
      'volumeInfo': {
        'title': 'Piranesi',
        'authors': ['Susanna Clarke'],
        'publishedDate': '2020-09-15',
        'pageCount': 272,
        'description': '<p>Piranesi lives in the House.</p><br>An &amp; more.',
        'categories': ['Fiction / Fantasy / Literary'],
        'industryIdentifiers': [
          {'type': 'ISBN_10', 'identifier': '163557563X'},
          {'type': 'ISBN_13', 'identifier': '9781635575637'},
        ],
      },
    },
    {
      'id': 'nodata',
      'volumeInfo': {
        'authors': ['No Title'],
      },
    },
  ],
};

void main() {
  test('parses volumes, skips ones without a title', () async {
    late Uri requested;
    final repo = GoogleBooksRepository(
      apiKey: 'test-key',
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(jsonEncode(_sampleBody), 200);
      }),
    );

    final results = await repo.search('piranesi');

    expect(results, hasLength(1));
    final book = results.single;
    expect(book.title, 'Piranesi');
    expect(book.author, 'Susanna Clarke');
    expect(book.year, 2020);
    expect(book.pages, 272);
    expect(book.isbn, '9781635575637'); // ISBN-13 preferred
    expect(book.tags, ['Fiction', 'Fantasy', 'Literary']);
    expect(book.about, contains('Piranesi lives in the House.'));
    expect(book.about, isNot(contains('<p>')));
    expect(book.about, contains('An & more.'));
    expect(requested.queryParameters['q'], 'piranesi');
    expect(requested.queryParameters['key'], 'test-key');
  });

  test('ISBN-looking queries use the isbn: operator', () async {
    late Uri requested;
    final repo = GoogleBooksRepository(
      apiKey: '',
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(jsonEncode(_sampleBody), 200);
      }),
    );

    await repo.search('978-1-63557-563-7');
    expect(requested.queryParameters['q'], 'isbn:9781635575637');
    expect(requested.queryParameters.containsKey('key'), isFalse);
  });

  test('findByIsbn returns null when nothing is found', () async {
    final repo = GoogleBooksRepository(
      client: MockClient(
        (_) async => http.Response(jsonEncode({'totalItems': 0}), 200),
      ),
    );
    expect(await repo.findByIsbn('9781635575637'), isNull);
  });

  test('maps quota and network errors to friendly messages', () async {
    final quota = GoogleBooksRepository(
      apiKey: '',
      client: MockClient((_) async => http.Response('{}', 429)),
    );
    expect(
      quota.search('x'),
      throwsA(
        isA<BooksException>().having(
          (e) => e.message,
          'message',
          contains('API key'),
        ),
      ),
    );

    final offline = GoogleBooksRepository(
      client: MockClient((_) async => throw http.ClientException('boom')),
    );
    expect(
      offline.search('x'),
      throwsA(
        isA<BooksException>().having(
          (e) => e.message,
          'message',
          contains('Network'),
        ),
      ),
    );
  });

  test('rejects an invalid ISBN', () {
    final repo = GoogleBooksRepository(
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    expect(repo.findByIsbn('12345'), throwsA(isA<BooksException>()));
  });
}
