import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get modifiedAt => dateTime()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get trashed => boolean().withDefault(const Constant(false))();
  TextColumn get pdfPath => text().nullable()();
  TextColumn get ocrText => text().withDefault(const Constant(''))();
  TextColumn get folder => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ScanPages extends Table {
  TextColumn get id => text()();
  TextColumn get documentId =>
      text().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get imagePath => text()();
  TextColumn get cropPath => text().nullable()();
  IntColumn get pageIndex => integer()();
  IntColumn get rotation => integer().withDefault(const Constant(0))();
  TextColumn get filter => text().withDefault(const Constant('original'))();
  TextColumn get ocrText => text().withDefault(const Constant(''))();
  TextColumn get ocrBoxes => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Documents, ScanPages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(documents, documents.folder);
        await m.addColumn(documents, documents.tags);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Stream<List<Document>> watchDocuments({
    String query = '',
    bool favoritesOnly = false,
    String sortBy = 'modified',
    String? folder,
  }) {
    final normalized = query.trim();
    final statement = select(documents)..where((d) => d.trashed.equals(false));
    statement.orderBy([
      switch (sortBy) {
        'name' => (d) => OrderingTerm.asc(d.title),
        'oldest' => (d) => OrderingTerm.asc(d.createdAt),
        'created' => (d) => OrderingTerm.desc(d.createdAt),
        _ => (d) => OrderingTerm.desc(d.modifiedAt),
      },
    ]);
    if (favoritesOnly) {
      statement.where((d) => d.favorite.equals(true));
    }
    if (folder != null) statement.where((d) => d.folder.equals(folder));
    if (normalized.isNotEmpty) {
      statement.where(
        (d) =>
            d.title.like('%$normalized%') |
            d.ocrText.like('%$normalized%') |
            d.tags.like('%$normalized%'),
      );
    }
    return statement.watch();
  }

  Stream<List<String>> watchFolders() =>
      (selectOnly(documents, distinct: true)
            ..addColumns([documents.folder])
            ..where(
              documents.trashed.equals(false) & documents.folder.isNotNull(),
            )
            ..orderBy([OrderingTerm.asc(documents.folder)]))
          .map((row) => row.read(documents.folder)!)
          .watch();

  Stream<List<Document>> watchTrash() =>
      (select(documents)
            ..where((d) => d.trashed.equals(true))
            ..orderBy([(d) => OrderingTerm.desc(d.modifiedAt)]))
          .watch();

  Future<void> moveToTrash(String documentId) =>
      (update(documents)..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(
          trashed: const Value(true),
          modifiedAt: Value(DateTime.now()),
        ),
      );

  Future<void> restoreFromTrash(String documentId) =>
      (update(documents)..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(
          trashed: const Value(false),
          modifiedAt: Value(DateTime.now()),
        ),
      );

  Stream<List<ScanPage>> watchPages(String documentId) =>
      (select(scanPages)
            ..where((p) => p.documentId.equals(documentId))
            ..orderBy([(p) => OrderingTerm.asc(p.pageIndex)]))
          .watch();

  Future<void> createDocument({
    required String id,
    required String title,
  }) async {
    final now = DateTime.now();
    await into(documents).insert(
      DocumentsCompanion.insert(
        id: id,
        title: title,
        createdAt: now,
        modifiedAt: now,
      ),
    );
  }

  Future<void> addPage({
    required String id,
    required String documentId,
    required String imagePath,
    required int pageIndex,
  }) => into(scanPages).insert(
    ScanPagesCompanion.insert(
      id: id,
      documentId: documentId,
      imagePath: imagePath,
      pageIndex: pageIndex,
    ),
  );

  Future<void> touchDocument(String documentId) =>
      (update(documents)..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(modifiedAt: Value(DateTime.now())),
      );

  Future<void> savePageOcr(String pageId, String text, String boxes) =>
      (update(scanPages)..where((p) => p.id.equals(pageId))).write(
        ScanPagesCompanion(ocrText: Value(text), ocrBoxes: Value(boxes)),
      );

  Future<void> saveDocumentOcr(String documentId, String text) =>
      (update(documents)..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(
          ocrText: Value(text),
          modifiedAt: Value(DateTime.now()),
        ),
      );

  Future<void> savePdf(String documentId, String path) =>
      (update(documents)..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(
          pdfPath: Value(path),
          modifiedAt: Value(DateTime.now()),
        ),
      );

  Future<void> renameDocument(String documentId, String title) =>
      (update(documents)..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(
          title: Value(title),
          modifiedAt: Value(DateTime.now()),
        ),
      );

  Future<void> organizeDocument(
    String documentId, {
    required String? folder,
    required String tags,
  }) => (update(documents)..where((d) => d.id.equals(documentId))).write(
    DocumentsCompanion(
      folder: Value(folder),
      tags: Value(tags),
      modifiedAt: Value(DateTime.now()),
    ),
  );

  Future<void> setFavorite(String documentId, bool favorite) =>
      (update(documents)..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(
          favorite: Value(favorite),
          modifiedAt: Value(DateTime.now()),
        ),
      );

  Future<void> reorderPages(String documentId, List<String> orderedIds) async {
    await transaction(() async {
      for (var index = 0; index < orderedIds.length; index++) {
        await (update(scanPages)..where(
              (p) =>
                  p.id.equals(orderedIds[index]) &
                  p.documentId.equals(documentId),
            ))
            .write(ScanPagesCompanion(pageIndex: Value(index)));
      }
      await touchDocument(documentId);
    });
  }

  Future<void> rotatePage(String pageId, int delta) async {
    final page = await (select(
      scanPages,
    )..where((p) => p.id.equals(pageId))).getSingle();
    await (update(scanPages)..where((p) => p.id.equals(pageId))).write(
      ScanPagesCompanion(rotation: Value((page.rotation + delta) % 360)),
    );
    await touchDocument(page.documentId);
  }

  Future<void> setPageFilter(String pageId, String filter) async {
    final page = await (select(
      scanPages,
    )..where((p) => p.id.equals(pageId))).getSingle();
    await (update(scanPages)..where((p) => p.id.equals(pageId))).write(
      ScanPagesCompanion(filter: Value(filter)),
    );
    await touchDocument(page.documentId);
  }

  Future<void> setPageCrop(String pageId, String? path) async {
    final page = await (select(
      scanPages,
    )..where((p) => p.id.equals(pageId))).getSingle();
    await transaction(() async {
      await (update(scanPages)..where((p) => p.id.equals(pageId))).write(
        ScanPagesCompanion(
          cropPath: Value(path),
          rotation: const Value(0),
          ocrText: const Value(''),
          ocrBoxes: const Value('[]'),
        ),
      );
      final pages =
          await (select(scanPages)
                ..where((p) => p.documentId.equals(page.documentId))
                ..orderBy([(p) => OrderingTerm.asc(p.pageIndex)]))
              .get();
      final text = pages
          .map((item) => item.ocrText)
          .where((value) => value.isNotEmpty)
          .join('\n\n');
      await (update(
        documents,
      )..where((d) => d.id.equals(page.documentId))).write(
        DocumentsCompanion(
          ocrText: Value(text),
          modifiedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> deletePage(String pageId) async {
    final page = await (select(
      scanPages,
    )..where((p) => p.id.equals(pageId))).getSingleOrNull();
    if (page == null) return;
    await (delete(scanPages)..where((p) => p.id.equals(pageId))).go();
    final remaining = await (select(
      scanPages,
    )..where((p) => p.documentId.equals(page.documentId))).get();
    await transaction(() async {
      for (var index = 0; index < remaining.length; index++) {
        await (update(scanPages)
              ..where((p) => p.id.equals(remaining[index].id)))
            .write(ScanPagesCompanion(pageIndex: Value(index)));
      }
      await touchDocument(page.documentId);
    });
  }

  Future<void> deleteDocument(String documentId) => transaction(() async {
    await (delete(
      scanPages,
    )..where((p) => p.documentId.equals(documentId))).go();
    await (delete(documents)..where((d) => d.id.equals(documentId))).go();
  });
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final directory = await getApplicationSupportDirectory();
  await Directory(directory.path).create(recursive: true);
  return NativeDatabase.createInBackground(
    File(p.join(directory.path, 'scanflow.sqlite')),
  );
});
