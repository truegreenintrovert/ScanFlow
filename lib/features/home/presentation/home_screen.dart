import 'dart:io';
import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/scanflow_logo.dart';
import '../../../core/widgets/scanflow_navigation_bar.dart';
import '../../../core/widgets/pdf_compression_level_dialog.dart';
import 'document_metadata_line.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(documentsProvider);
    final selectedIds = ref.watch(selectedDocumentsProvider);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 62,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: ScanFlowLogo(size: 40),
        ),
        title: Text(
          selectedIds.isEmpty ? 'ScanFlow' : '${selectedIds.length} selected',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: selectedIds.isNotEmpty
            ? [
                IconButton(
                  tooltip: 'Favorite selected',
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
                    for (final id in selectedIds) {
                      await db.setFavorite(id, true);
                    }
                    ref.read(selectedDocumentsProvider.notifier).clear();
                  },
                  icon: const Icon(Icons.star_outline_rounded),
                ),
                IconButton(
                  tooltip: 'Move selected to trash',
                  onPressed: () => _bulkTrash(context, ref, selectedIds),
                  icon: const Icon(Icons.delete_outline),
                ),
                IconButton(
                  tooltip: 'Cancel selection',
                  onPressed: ref.read(selectedDocumentsProvider.notifier).clear,
                  icon: const Icon(Icons.close),
                ),
              ]
            : [
                IconButton(
                  tooltip: 'Import a PDF',
                  onPressed: () => _importPdf(context, ref),
                  icon: const Icon(Icons.file_open_outlined),
                ),
                IconButton(
                  tooltip: 'Trash',
                  onPressed: () => context.push('/trash'),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
                PopupMenuButton<String>(
                  tooltip: 'PDF tools',
                  onSelected: (action) => _runLocalPdfAction(
                    context,
                    ref,
                    merge: action == 'merge',
                  ),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'merge',
                      child: Row(
                        children: [
                          Icon(Icons.call_merge_rounded),
                          SizedBox(width: 12),
                          Text('Merge PDFs'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'compress',
                      child: Row(
                        children: [
                          Icon(Icons.compress_rounded),
                          SizedBox(width: 12),
                          Text('Compress PDFs'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your documents',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Everything you scan, right here.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) => ref
                          .read(documentSearchProvider.notifier)
                          .updateQuery(value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search documents or recognized text',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.document_scanner_outlined,
                            title: 'Scan pages',
                            subtitle: 'Capture a document',
                            onTap: () => context.push('/scan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.picture_as_pdf_outlined,
                            title: 'Import PDF',
                            subtitle: 'Open an existing file',
                            onTap: () => _importPdf(context, ref),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilterChip(
                      selected: ref.watch(favoritesOnlyProvider),
                      avatar: const Icon(Icons.star_rounded, size: 18),
                      label: const Text('Favorites'),
                      onSelected: (_) =>
                          ref.read(favoritesOnlyProvider.notifier).toggle(),
                    ),
                    ref
                        .watch(foldersProvider)
                        .maybeWhen(
                          data: (folders) => folders.isEmpty
                              ? const SizedBox.shrink()
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ChoiceChip(
                                        label: const Text('All folders'),
                                        selected:
                                            ref.watch(selectedFolderProvider) ==
                                            null,
                                        onSelected: (_) => ref
                                            .read(
                                              selectedFolderProvider.notifier,
                                            )
                                            .select(null),
                                      ),
                                      const SizedBox(width: 7),
                                      for (final folder in folders) ...[
                                        ChoiceChip(
                                          label: Text(folder),
                                          selected:
                                              ref.watch(
                                                selectedFolderProvider,
                                              ) ==
                                              folder,
                                          onSelected: (_) => ref
                                              .read(
                                                selectedFolderProvider.notifier,
                                              )
                                              .select(folder),
                                        ),
                                        const SizedBox(width: 7),
                                      ],
                                    ],
                                  ),
                                ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          ref.watch(documentSearchProvider).isEmpty
                              ? 'Recent scans'
                              : 'Search results',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        docs.maybeWhen(
                          data: (items) => Text(
                            '${items.length}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Sort documents',
                          icon: const Icon(Icons.sort),
                          initialValue: ref.watch(documentSortProvider),
                          onSelected: ref
                              .read(documentSortProvider.notifier)
                              .select,
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'modified',
                              child: Text('Recently modified'),
                            ),
                            PopupMenuItem(
                              value: 'created',
                              child: Text('Newest first'),
                            ),
                            PopupMenuItem(
                              value: 'oldest',
                              child: Text('Oldest first'),
                            ),
                            PopupMenuItem(
                              value: 'name',
                              child: Text('Name, A to Z'),
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: ref.watch(documentListViewProvider)
                              ? 'Show grid'
                              : 'Show list',
                          onPressed: ref
                              .read(documentListViewProvider.notifier)
                              .toggle,
                          icon: Icon(
                            ref.watch(documentListViewProvider)
                                ? Icons.grid_view_rounded
                                : Icons.view_agenda_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            docs.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: _ErrorState(
                  message: 'Could not open your library. $error',
                ),
              ),
              data: (items) => items.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(onScan: () => context.push('/scan')),
                    )
                  : ref.watch(documentListViewProvider)
                  ? SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      sliver: SliverList.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _DocumentListRow(
                            document: items[index],
                            selected: selectedIds.contains(items[index].id),
                            selectionMode: selectedIds.isNotEmpty,
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      sliver: SliverGrid.builder(
                        itemCount: items.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              mainAxisExtent: 258,
                              crossAxisSpacing: 13,
                              mainAxisSpacing: 14,
                            ),
                        itemBuilder: (context, index) => _DocumentCard(
                          document: items[index],
                          selected: selectedIds.contains(items[index].id),
                          selectionMode: selectedIds.isNotEmpty,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ScanFlowNavigationBar(currentIndex: 0),
    );
  }

  Future<void> _importPdf(BuildContext context, WidgetRef ref) async {
    String? newDocumentId;
    try {
      final source = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (source == null) return;
      final id = const Uuid().v4();
      newDocumentId = id;
      final title = p.basenameWithoutExtension(source.name);
      final storage = ref.read(scanStorageProvider);
      await ref
          .read(databaseProvider)
          .createDocument(
            id: id,
            title: title.isEmpty ? 'Imported PDF' : title,
          );
      final path = await storage.pdfPath(id);
      final destination = File(path).openWrite();
      try {
        await destination.addStream(source.readAsByteStream());
        await destination.flush();
      } finally {
        await destination.close();
      }
      final db = ref.read(databaseProvider);
      await db.savePdf(id, path);
      var pageIndex = 0;
      await for (final raster in Printing.raster(
        await File(path).readAsBytes(),
        dpi: 144,
      )) {
        final pageImage = await raster.toPng();
        final imagePath = await storage.savePage(id, pageImage);
        await db.addPage(
          id: const Uuid().v4(),
          documentId: id,
          imagePath: imagePath,
          pageIndex: pageIndex++,
        );
      }
      if (pageIndex == 0) throw const FormatException('The PDF has no pages.');
      if (context.mounted) context.push('/document/$id');
    } on FileSystemException catch (error) {
      if (newDocumentId != null) {
        await ref.read(databaseProvider).deleteDocument(newDocumentId);
        await ref.read(scanStorageProvider).removeDocumentAssets(newDocumentId);
      }
      if (context.mounted) {
        _showError(context, 'Could not copy this PDF: ${error.message}');
      }
    } catch (error) {
      if (newDocumentId != null) {
        await ref.read(databaseProvider).deleteDocument(newDocumentId);
        await ref.read(scanStorageProvider).removeDocumentAssets(newDocumentId);
      }
      if (context.mounted) {
        _showError(context, 'Could not import this file. $error');
      }
    }
  }

  Future<void> _runLocalPdfAction(
    BuildContext context,
    WidgetRef ref, {
    required bool merge,
  }) async {
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: merge ? 'Select PDFs to merge' : 'Select PDFs to compress',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (!context.mounted) return;
      if (files.isEmpty) return;
      if (merge && files.length < 2) {
        _showError(context, 'Select at least two PDFs to merge.');
        return;
      }
      final level = merge
          ? null
          : await showPdfCompressionLevelDialog(
              context,
              saveLocation: 'Downloads/ScanFlow',
            );
      if (!context.mounted || (!merge && level == null)) return;

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 18),
              Expanded(
                child: Text(merge ? 'Merging PDFs…' : 'Compressing PDFs…'),
              ),
            ],
          ),
        ),
      );

      String message;
      try {
        final actions = ref.read(pdfFileActionsProvider);
        final operations = ref.read(localPdfOperationsProvider);
        if (merge) {
          final outputPath = await operations.merge(files);
          final savedLocation = await actions.saveToDownloads(
            outputPath,
            'ScanFlow-merged.pdf',
          );
          if (savedLocation == null) {
            throw StateError('The merged PDF was not saved.');
          }
          message = 'Merged PDF saved to $savedLocation.';
        } else {
          final outputs = await operations.compress(files, level: level!);
          var totalOriginalBytes = 0;
          var totalCompressedBytes = 0;
          for (final output in outputs) {
            final savedLocation = await actions.saveToDownloads(
              output.path,
              output.fileName,
            );
            if (savedLocation == null) {
              throw StateError('Could not save ${output.fileName}.');
            }
            totalOriginalBytes += output.originalBytes;
            totalCompressedBytes += output.compressedBytes;
          }
          final savedBytes = totalOriginalBytes - totalCompressedBytes;
          final savings = savedBytes > 0
              ? '${_formatBytes(totalOriginalBytes)} → ${_formatBytes(totalCompressedBytes)}; ${_formatBytes(savedBytes)} saved.'
              : savedBytes < 0
              ? '${_formatBytes(totalOriginalBytes)} → ${_formatBytes(totalCompressedBytes)}; output is ${_formatBytes(-savedBytes)} larger.'
              : 'No size change (${_formatBytes(totalOriginalBytes)}).';
          message = outputs.length == 1
              ? 'Compressed copy saved to Downloads/ScanFlow. $savings'
              : '${outputs.length} compressed copies saved to Downloads/ScanFlow. $savings';
        }
      } finally {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (context.mounted) {
        _showError(
          context,
          'Could not ${merge ? 'merge' : 'compress'} PDFs. $error',
        );
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1000) return '$bytes B';
    if (bytes < 1000 * 1000) {
      return '${(bytes / 1000).toStringAsFixed(1)} KB';
    }
    return '${(bytes / 1000000).toStringAsFixed(2)} MB';
  }

  void _showError(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _bulkTrash(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedIds,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move ${selectedIds.length} documents to trash?'),
        content: const Text('You can restore documents from Trash later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Move to trash'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = ref.read(databaseProvider);
    for (final id in selectedIds) {
      await db.moveToTrash(id);
    }
    ref.read(selectedDocumentsProvider.notifier).clear();
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 13),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DocumentListRow extends ConsumerWidget {
  const _DocumentListRow({
    required this.document,
    required this.selected,
    required this.selectionMode,
  });
  final Document document;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return Card(
      child: ListTile(
        selected: selected,
        onLongPress: () =>
            ref.read(selectedDocumentsProvider.notifier).toggle(document.id),
        onTap: () {
          if (selectionMode) {
            ref.read(selectedDocumentsProvider.notifier).toggle(document.id);
          } else {
            context.push('/document/${document.id}');
          }
        },
        leading: SizedBox(
          width: 54,
          height: 58,
          child: FutureBuilder<List<ScanPage>>(
            future:
                (db.select(db.scanPages)
                      ..where((page) => page.documentId.equals(document.id))
                      ..orderBy([(page) => OrderingTerm.asc(page.pageIndex)]))
                    .get(),
            builder: (context, snapshot) {
              final pages = snapshot.data;
              if (pages == null || pages.isEmpty) {
                return const Icon(Icons.picture_as_pdf_outlined);
              }
              final path = pages.first.cropPath ?? pages.first.imagePath;
              return ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.description),
                ),
              );
            },
          ),
        ),
        title: Text(
          document.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: DocumentMetadataLine(
          database: db,
          document: document,
          prefix: _dateLabel(document.modifiedAt),
        ),
        trailing: selectionMode
            ? Icon(selected ? Icons.check_circle : Icons.circle_outlined)
            : IconButton(
                tooltip: document.favorite ? 'Remove favorite' : 'Add favorite',
                onPressed: () =>
                    db.setFavorite(document.id, !document.favorite),
                icon: Icon(
                  document.favorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: document.favorite ? const Color(0xffd08a00) : null,
                ),
              ),
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  const _DocumentCard({
    required this.document,
    required this.selected,
    required this.selectionMode,
  });
  final Document document;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () =>
            ref.read(selectedDocumentsProvider.notifier).toggle(document.id),
        onTap: () {
          if (selectionMode) {
            ref.read(selectedDocumentsProvider.notifier).toggle(document.id);
          } else {
            context.push('/document/${document.id}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<List<ScanPage>>(
                future:
                    (db.select(db.scanPages)
                          ..where((p) => p.documentId.equals(document.id))
                          ..orderBy([(p) => OrderingTerm.asc(p.pageIndex)]))
                        .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.isNotEmpty &&
                      File(
                        snapshot.data!.first.cropPath ??
                            snapshot.data!.first.imagePath,
                      ).existsSync()) {
                    return Image.file(
                      File(
                        snapshot.data!.first.cropPath ??
                            snapshot.data!.first.imagePath,
                      ),
                      fit: BoxFit.cover,
                    );
                  }
                  return ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.65),
                    child: Center(
                      child: Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 6, 7),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          child: DocumentMetadataLine(
                            database: db,
                            document: document,
                            prefix: _dateLabel(document.modifiedAt),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: selectionMode
                        ? () => ref
                              .read(selectedDocumentsProvider.notifier)
                              .toggle(document.id)
                        : () => db.setFavorite(document.id, !document.favorite),
                    icon: selectionMode
                        ? Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          )
                        : Icon(
                            document.favorite
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: document.favorite
                                ? const Color(0xffd08a00)
                                : null,
                          ),
                    visualDensity: VisualDensity.compact,
                    tooltip: selectionMode
                        ? (selected ? 'Deselect' : 'Select')
                        : (document.favorite
                              ? 'Remove favorite'
                              : 'Add favorite'),
                  ),
                  if (!selectionMode)
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'rename') {
                          await _rename(context, ref);
                          return;
                        }
                        if (value == 'organize') {
                          await _organize(context, ref);
                          return;
                        }
                        if (value == 'share') {
                          await _sharePdf(context, ref);
                          return;
                        }
                        if (value == 'save') {
                          await _savePdf(context, ref);
                          return;
                        }
                        if (value == 'edit') {
                          context.push('/edit/${document.id}');
                          return;
                        }
                        if (value == 'delete') await _delete(context, ref);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit pages'),
                        ),
                        const PopupMenuItem(
                          value: 'share',
                          child: Text('Share PDF'),
                        ),
                        const PopupMenuItem(
                          value: 'save',
                          child: Text('Save to device'),
                        ),
                        const PopupMenuItem(
                          value: 'organize',
                          child: Text('Folder and tags'),
                        ),
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text('Rename'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: document.title);
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename document'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Document name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (title != null && title.isNotEmpty) {
      await ref.read(databaseProvider).renameDocument(document.id, title);
    }
  }

  Future<void> _sharePdf(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final path = await _ensurePdf(context, ref);
    if (path == null) return;
    try {
      await ref.read(pdfFileActionsProvider).share(path, document.title);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not share the PDF. $error')),
      );
    }
  }

  Future<void> _savePdf(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final path = await _ensurePdf(context, ref);
    if (path == null) return;
    try {
      final saved = await ref
          .read(pdfFileActionsProvider)
          .saveToDevice(path, '${document.title}.pdf');
      if (saved) {
        messenger.showSnackBar(
          const SnackBar(content: Text('PDF saved to your device.')),
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save the PDF. $error')),
      );
    }
  }

  Future<String?> _ensurePdf(BuildContext context, WidgetRef ref) async {
    final existing = document.pdfPath;
    if (existing != null && await File(existing).exists()) return existing;
    if (!context.mounted) return null;
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 18),
            Expanded(child: Text('Preparing your PDF…')),
          ],
        ),
      ),
    );
    try {
      final db = ref.read(databaseProvider);
      final pages = await db.watchPages(document.id).first;
      if (pages.isEmpty) throw StateError('This document has no scan pages.');
      return await ref
          .read(pdfServiceProvider)
          .createDocument(
            db,
            document,
            pages,
            searchable: pages.any((page) => page.ocrText.trim().isNotEmpty),
          );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not prepare the PDF. $error')),
      );
      return null;
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _organize(BuildContext context, WidgetRef ref) async {
    final folderController = TextEditingController(text: document.folder ?? '');
    final tagsController = TextEditingController(text: document.tags);
    final result = await showDialog<(String, String)?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Organize document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: folderController,
              decoration: const InputDecoration(
                labelText: 'Folder',
                hintText: 'For example, Work',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Separate tags with commas',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, (
              folderController.text.trim(),
              tagsController.text.trim(),
            )),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final tags = result.$2
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .join(', ');
    await ref
        .read(databaseProvider)
        .organizeDocument(
          document.id,
          folder: result.$1.isEmpty ? null : result.$1,
          tags: tags,
        );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text(
          '“${document.title}” and its saved scan pages will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).moveToTrash(document.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.document_scanner_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Your next scan starts here',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture paper pages, recognize the text, then save a PDF to your library.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Start scanning'),
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}

String _dateLabel(DateTime date) {
  final now = DateTime.now();
  if (now.year == date.year && now.month == date.month && now.day == date.day) {
    return 'Today';
  }
  return '${date.day}/${date.month}/${date.year}';
}
