import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/services/document_edge_correction.dart';
import '../core/services/image_processing.dart';
import '../core/services/local_pdf_operations.dart';
import '../core/services/ocr_service.dart';
import '../core/services/pdf_file_actions.dart';
import '../core/services/pdf_service.dart';
import '../core/storage/scan_storage.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final scanStorageProvider = Provider<ScanStorage>((ref) => ScanStorage());
final imageProcessingProvider = Provider<ImageProcessing>(
  (ref) => ImageProcessing(),
);
final edgeCorrectionProvider = Provider<DocumentEdgeCorrection>(
  (ref) => DocumentEdgeCorrection(),
);
final pdfFileActionsProvider = Provider<PdfFileActions>(
  (ref) => PdfFileActions(),
);
final localPdfOperationsProvider = Provider<LocalPdfOperations>(
  (ref) => LocalPdfOperations(),
);
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});
final pdfServiceProvider = Provider<PdfService>(
  (ref) => PdfService(
    ref.watch(scanStorageProvider),
    ref.watch(imageProcessingProvider),
  ),
);

final documentSearchProvider = NotifierProvider<DocumentSearch, String>(
  DocumentSearch.new,
);
final favoritesOnlyProvider = NotifierProvider<FavoritesOnly, bool>(
  FavoritesOnly.new,
);
final documentSortProvider = NotifierProvider<DocumentSort, String>(
  DocumentSort.new,
);
final documentListViewProvider = NotifierProvider<DocumentListView, bool>(
  DocumentListView.new,
);
final selectedDocumentsProvider =
    NotifierProvider<SelectedDocuments, Set<String>>(SelectedDocuments.new);
final selectedFolderProvider = NotifierProvider<SelectedFolder, String?>(
  SelectedFolder.new,
);
final foldersProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(databaseProvider).watchFolders(),
);

class SelectedFolder extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? folder) => state = folder;
}

class SelectedDocuments extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};
  void toggle(String id) => state = state.contains(id)
      ? Set.unmodifiable({...state}..remove(id))
      : Set.unmodifiable({...state, id});
  void clear() => state = const {};
}

class DocumentSort extends Notifier<String> {
  @override
  String build() => 'modified';
  void select(String value) => state = value;
}

class DocumentListView extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

class FavoritesOnly extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

class DocumentSearch extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
}

final documentsProvider = StreamProvider<List<Document>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchDocuments(
        query: ref.watch(documentSearchProvider),
        favoritesOnly: ref.watch(favoritesOnlyProvider),
        sortBy: ref.watch(documentSortProvider),
        folder: ref.watch(selectedFolderProvider),
      ),
);
