import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/scanflow_navigation_bar.dart';
import 'document_metadata_line.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: StreamBuilder(
        stream: database.watchDocuments(sortBy: 'modified'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load history. ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!;
          if (documents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 44),
                    const SizedBox(height: 12),
                    Text(
                      'Your scans will appear here.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => context.go('/scan'),
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: const Text('Start scanning'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final document = documents[index];
              final modified = document.modifiedAt;
              final date =
                  '${modified.day}/${modified.month}/${modified.year} · '
                  '${modified.hour.toString().padLeft(2, '0')}:'
                  '${modified.minute.toString().padLeft(2, '0')}';
              return Card(
                child: ListTile(
                  leading: _HistoryPageThumbnail(
                    database: database,
                    documentId: document.id,
                  ),
                  title: Text(
                    document.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: DocumentMetadataLine(
                    database: database,
                    document: document,
                    prefix: 'Last updated $date',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/document/${document.id}'),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const ScanFlowNavigationBar(currentIndex: 2),
    );
  }
}

class _HistoryPageThumbnail extends StatefulWidget {
  const _HistoryPageThumbnail({
    required this.database,
    required this.documentId,
  });

  final AppDatabase database;
  final String documentId;

  @override
  State<_HistoryPageThumbnail> createState() => _HistoryPageThumbnailState();
}

class _HistoryPageThumbnailState extends State<_HistoryPageThumbnail> {
  late Future<List<ScanPage>> _pages;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _HistoryPageThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentId != widget.documentId) _load();
  }

  void _load() {
    _pages =
        (widget.database.select(widget.database.scanPages)
              ..where((page) => page.documentId.equals(widget.documentId))
              ..orderBy([(page) => OrderingTerm.asc(page.pageIndex)]))
            .get();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 54,
    height: 62,
    child: FutureBuilder<List<ScanPage>>(
      future: _pages,
      builder: (context, snapshot) {
        final pages = snapshot.data;
        if (pages == null || pages.isEmpty) {
          return Icon(
            Icons.description_outlined,
            color: Theme.of(context).colorScheme.primary,
          );
        }
        final path = pages.first.cropPath ?? pages.first.imagePath;
        return ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    ),
  );
}
