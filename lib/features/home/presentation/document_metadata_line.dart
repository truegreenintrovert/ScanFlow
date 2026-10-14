import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class DocumentMetadataLine extends StatefulWidget {
  const DocumentMetadataLine({
    required this.database,
    required this.document,
    required this.prefix,
    super.key,
  });

  final AppDatabase database;
  final Document document;
  final String prefix;

  @override
  State<DocumentMetadataLine> createState() => _DocumentMetadataLineState();
}

class _DocumentMetadataLineState extends State<DocumentMetadataLine> {
  late Future<(int, int?)> _stats;

  @override
  void initState() {
    super.initState();
    _stats = _loadStats();
  }

  @override
  void didUpdateWidget(covariant DocumentMetadataLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id ||
        oldWidget.document.pdfPath != widget.document.pdfPath) {
      _stats = _loadStats();
    }
  }

  Future<(int, int?)> _loadStats() async {
    final pages = await (widget.database.select(
      widget.database.scanPages,
    )..where((page) => page.documentId.equals(widget.document.id))).get();
    final path = widget.document.pdfPath;
    int? bytes;
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) bytes = await file.length();
      } on FileSystemException {
        // A missing PDF still has a useful page count.
      }
    }
    return (pages.length, bytes);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<(int, int?)>(
    future: _stats,
    builder: (context, snapshot) {
      final count = snapshot.data?.$1;
      final bytes = snapshot.data?.$2;
      final parts = <String>[];
      if (count != null) parts.add('$count ${count == 1 ? 'page' : 'pages'}');
      if (bytes != null) parts.add(_formatBytes(bytes));
      parts.add(widget.prefix);
      return Text(
        parts.join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    },
  );
}

String _formatBytes(int bytes) {
  if (bytes < 1000) return '$bytes B';
  if (bytes < 1000 * 1000) {
    return '${(bytes / 1000).toStringAsFixed(1)} KB';
  }
  return '${(bytes / 1000000).toStringAsFixed(2)} MB';
}
