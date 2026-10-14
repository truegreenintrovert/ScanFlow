import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting();
    await database.customSelect('SELECT 1').get();
  });

  tearDown(() async => database.close());

  test('stores documents and keeps page order editable', () async {
    await database.createDocument(id: 'doc-a', title: 'Receipt');
    await database.addPage(
      id: 'page-1',
      documentId: 'doc-a',
      imagePath: '/one.jpg',
      pageIndex: 0,
    );
    await database.addPage(
      id: 'page-2',
      documentId: 'doc-a',
      imagePath: '/two.jpg',
      pageIndex: 1,
    );

    await database.reorderPages('doc-a', ['page-2', 'page-1']);
    final pages = await database.watchPages('doc-a').first;

    expect(pages.map((page) => page.id), ['page-2', 'page-1']);
    expect(pages.map((page) => page.pageIndex), [0, 1]);
  });

  test('searches stored OCR and toggles favorites', () async {
    await database.createDocument(id: 'doc-b', title: 'Notes');
    await database.saveDocumentOcr('doc-b', 'the local search phrase');
    await database.setFavorite('doc-b', true);

    final matches = await database.watchDocuments(query: 'search phrase').first;

    expect(matches, hasLength(1));
    expect(matches.single.title, 'Notes');
    expect(matches.single.favorite, isTrue);
  });

  test('moves a document to trash and restores it', () async {
    await database.createDocument(id: 'doc-c', title: 'Archived');

    await database.moveToTrash('doc-c');
    expect(await database.watchDocuments().first, isEmpty);
    expect((await database.watchTrash().first).single.title, 'Archived');

    await database.restoreFromTrash('doc-c');
    expect((await database.watchDocuments().first).single.title, 'Archived');
    expect(await database.watchTrash().first, isEmpty);
  });
}
