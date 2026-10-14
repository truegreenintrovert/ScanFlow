import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/pdf_compression_level_dialog.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({required this.documentId, super.key});
  final String documentId;
  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    return FutureBuilder<Document?>(
      future: (db.select(
        db.documents,
      )..where((d) => d.id.equals(widget.documentId))).getSingleOrNull(),
      builder: (context, snapshot) {
        final document = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (document == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('This document is no longer in your library.'),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              document.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                tooltip: 'Share PDF',
                onPressed: () => _sharePdf(document),
                icon: const Icon(Icons.share_outlined),
              ),
              IconButton(
                tooltip: 'Save PDF to device',
                onPressed: () => _savePdf(document),
                icon: const Icon(Icons.download_outlined),
              ),
              PopupMenuButton<String>(
                onSelected: (action) => _menuAction(action, document),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'compress', child: Text('Compress PDF')),
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'edit', child: Text('Edit pages')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete document'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '${document.createdAt.day}/${document.createdAt.month}/${document.createdAt.year}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    document.pdfPath != null &&
                        File(document.pdfPath!).existsSync()
                    ? PdfPreview.builder(
                        build: (format) =>
                            File(document.pdfPath!).readAsBytes(),
                        pagesBuilder: (context, pages) => LayoutBuilder(
                          builder: (context, constraints) {
                            final pageWidth = constraints.maxWidth
                                .clamp(1.0, double.infinity)
                                .toDouble();
                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 18),
                              itemCount: pages.length,
                              itemBuilder: (context, index) {
                                final page = pages[index];
                                final ratio = page.aspectRatio > 0
                                    ? page.aspectRatio
                                    : 1.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Center(
                                    child: _PinchZoomPdfPage(
                                      image: page.image,
                                      width: pageWidth,
                                      height: pageWidth / ratio,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        allowPrinting: true,
                        allowSharing: false,
                        pdfFileName: '${document.title}.pdf',
                        dpi: 96,
                        loadingWidget: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : StreamBuilder<List<ScanPage>>(
                        stream: db.watchPages(document.id),
                        builder: (context, pages) =>
                            pages.hasData && pages.data!.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: pages.data!.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(
                                        pages.data![index].cropPath ??
                                            pages.data![index].imagePath,
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            : const Center(
                                child: Text('No PDF or page images found.'),
                              ),
                      ),
              ),
            ],
          ),
          floatingActionButton: document.pdfPath == null
              ? FloatingActionButton.extended(
                  onPressed: () => context.push('/edit/${document.id}'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit pages'),
                )
              : null,
        );
      },
    );
  }

  Future<void> _sharePdf(Document document) async {
    final path = await _ensurePdf(document);
    if (!mounted || path == null) return;
    try {
      await ref.read(pdfFileActionsProvider).share(path, document.title);
    } catch (error) {
      _notify('Could not share the PDF. $error');
    }
  }

  Future<void> _savePdf(Document document) async {
    final path = await _ensurePdf(document);
    if (!mounted || path == null) return;
    try {
      final saved = await ref
          .read(pdfFileActionsProvider)
          .saveToDevice(path, '${document.title}.pdf');
      if (saved) _notify('PDF saved to your device.');
    } catch (error) {
      _notify('Could not save the PDF. $error');
    }
  }

  Future<void> _compressPdf(Document document) async {
    final level = await showPdfCompressionLevelDialog(
      context,
      saveLocation: 'Downloads/ScanFlow',
    );
    if (!mounted || level == null) return;
    final sourcePath = await _ensurePdf(document);
    if (!mounted || sourcePath == null) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 18),
            Expanded(child: Text('Compressing PDF…')),
          ],
        ),
      ),
    );

    String? compressedPath;
    int originalBytes = 0;
    int compressedBytes = 0;
    try {
      originalBytes = await File(sourcePath).length();
      final database = ref.read(databaseProvider);
      final pages = await database.watchPages(document.id).first;
      if (pages.isEmpty) throw StateError('This document has no scan pages.');
      compressedPath = await ref
          .read(pdfServiceProvider)
          .createCompressedCopy(
            database,
            document,
            pages,
            searchable: pages.any((page) => page.ocrText.trim().isNotEmpty),
            level: level,
          );
      compressedBytes = await File(compressedPath).length();
    } catch (error) {
      _notify('Could not compress the PDF. $error');
      return;
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
    if (!mounted) return;

    final savedBytes = originalBytes - compressedBytes;
    final savingText = savedBytes > 0
        ? '${_fileSize(savedBytes)} smaller (${(savedBytes * 100 / originalBytes).round()}% saved)'
        : savedBytes < 0
        ? '${_fileSize(-savedBytes)} larger'
        : 'No size change';
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Compressed PDF ready'),
        content: Text(
          '${_fileSize(originalBytes)} → ${_fileSize(compressedBytes)}\n$savingText\n\nSizes use decimal MB to match file managers.\nSave location: Downloads/ScanFlow',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'share'),
            child: const Text('Share copy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'save'),
            child: const Text('Save to Downloads'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    try {
      if (action == 'save') {
        final savedLocation = await ref
            .read(pdfFileActionsProvider)
            .saveToDownloads(
              compressedPath,
              '${document.title}-compressed.pdf',
            );
        if (savedLocation != null) {
          _notify('Compressed PDF saved to $savedLocation.');
        }
      } else if (action == 'share') {
        await ref
            .read(pdfFileActionsProvider)
            .share(compressedPath, '${document.title} compressed');
      }
    } catch (error) {
      _notify('Could not export the compressed PDF. $error');
    }
  }

  Future<String?> _ensurePdf(Document document) async {
    final path = document.pdfPath;
    if (path != null && await File(path).exists()) return path;
    if (!mounted) return null;
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
      final output = await ref
          .read(pdfServiceProvider)
          .createDocument(
            db,
            document,
            pages,
            searchable: pages.any((page) => page.ocrText.trim().isNotEmpty),
          );
      if (mounted) setState(() {});
      return output;
    } catch (error) {
      _notify('Could not prepare the PDF. $error');
      return null;
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _menuAction(String action, Document document) async {
    final db = ref.read(databaseProvider);
    if (action == 'compress') {
      await _compressPdf(document);
      return;
    }
    if (action == 'edit') {
      context.push('/edit/${document.id}');
      return;
    }
    if (action == 'rename') {
      final controller = TextEditingController(text: document.title);
      final title = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rename document'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Document name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (title != null && title.isNotEmpty) {
        await db.renameDocument(document.id, title);
      }
      return;
    }
    if (action == 'delete') {
      final remove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete document?'),
          content: Text('“${document.title}” will be removed from ScanFlow.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (remove == true) {
        await db.moveToTrash(document.id);
        if (mounted) context.go('/');
      }
    }
  }

  void _notify(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

String _fileSize(int bytes) {
  if (bytes < 1000) return '$bytes B';
  if (bytes < 1000 * 1000) {
    return '${(bytes / 1000).toStringAsFixed(1)} KB';
  }
  return '${(bytes / 1000000).toStringAsFixed(2)} MB';
}

/// A page-local pinch surface that leaves one-finger vertical swipes to the
/// surrounding multi-page list.
class _PinchZoomPdfPage extends StatefulWidget {
  const _PinchZoomPdfPage({
    required this.image,
    required this.width,
    required this.height,
  });

  final ImageProvider image;
  final double width;
  final double height;

  @override
  State<_PinchZoomPdfPage> createState() => _PinchZoomPdfPageState();
}

class _PinchZoomPdfPageState extends State<_PinchZoomPdfPage> {
  final Map<int, Offset> _pointers = {};
  double _scale = 1;
  double _startScale = 1;
  double _startDistance = 0;
  Offset _startFocalPoint = Offset.zero;
  Offset _sceneFocalPoint = Offset.zero;
  Offset _translation = Offset.zero;

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;
    if (_pointers.length == 2) {
      final points = _pointers.values.toList();
      _startDistance = (points[0] - points[1]).distance;
      _startScale = _scale;
      _startFocalPoint = (points[0] + points[1]) / 2;
      _sceneFocalPoint = (_startFocalPoint - _translation) / _scale;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;
    if (_pointers.length < 2 || _startDistance <= 0) return;

    final points = _pointers.values.toList();
    final distance = (points[0] - points[1]).distance;
    final focalPoint = (points[0] + points[1]) / 2;
    final nextScale = (_startScale * distance / _startDistance)
        .clamp(1.0, 5.0)
        .toDouble();
    final rawTranslation = focalPoint - _sceneFocalPoint * nextScale;
    final nextTranslation = nextScale == 1
        ? Offset.zero
        : Offset(
            rawTranslation.dx.clamp(widget.width * (1 - nextScale), 0.0),
            rawTranslation.dy.clamp(widget.height * (1 - nextScale), 0.0),
          );

    setState(() {
      _scale = nextScale;
      _translation = nextTranslation;
    });
  }

  void _onPointerUp(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.length < 2) _startDistance = 0;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    height: widget.height,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRect(
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: Transform.translate(
            offset: _translation,
            child: Transform.scale(
              alignment: Alignment.topLeft,
              scale: _scale,
              child: Image(
                image: widget.image,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
