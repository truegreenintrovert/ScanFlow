import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/image_processing.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({required this.documentId, super.key});
  final String documentId;
  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final PageController _pageController = PageController();
  String? _selectedPageId;
  String? _pageOrderKey;
  String? _cropPageId;
  String? _cropSourceKey;
  String? _loadingCropSourceKey;
  ScanPage? _queuedCropPage;
  String? _queuedCropSourceKey;
  Uint8List? _cropImage;
  CropController? _cropController;
  Timer? _cropApplyTimer;
  bool _cropReady = false;
  bool _cropAutoApplyInProgress = false;
  bool _savingCrop = false;

  @override
  void dispose() {
    _cropApplyTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<ScanPage>>(
      stream: db.watchPages(widget.documentId),
      builder: (context, snapshot) {
        final pages = snapshot.data ?? const <ScanPage>[];
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Could not open this scan: ${snapshot.error}'),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            pages.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (pages.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This scan has no pages.')),
          );
        }
        final selectedIndex = pages.indexWhere(
          (page) => page.id == _selectedPageId,
        );
        final index = selectedIndex < 0 ? 0 : selectedIndex;
        final page = pages[index];
        final pageCropSourceKey =
            '${page.id}:${page.cropPath ?? page.imagePath}:${page.rotation}';
        if ((_cropPageId != page.id || _cropSourceKey != pageCropSourceKey) &&
            _loadingCropSourceKey != pageCropSourceKey &&
            !(_cropAutoApplyInProgress && _cropPageId == page.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadCropPreview(page, pageCropSourceKey);
          });
        }
        final pageOrderKey = pages.map((page) => page.id).join('|');
        if (_pageOrderKey != pageOrderKey) {
          _pageOrderKey = pageOrderKey;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                _pageController.hasClients &&
                _pageController.page?.round() != index) {
              _pageController.jumpToPage(index);
            }
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: FutureBuilder<Document?>(
              future:
                  (db.select(db.documents)
                        ..where((d) => d.id.equals(widget.documentId)))
                      .getSingleOrNull(),
              builder: (context, snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.data?.title ?? 'Edit scan',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Page ${index + 1} of ${pages.length}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Add page',
                onPressed: () => _addPage(pages.length),
                icon: const Icon(Icons.add_photo_alternate_outlined),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) => setState(() {
                      _selectedPageId = pages[index].id;
                      _cropPageId = null;
                      _cropImage = null;
                      _cropController = null;
                      _cropReady = false;
                      _cropAutoApplyInProgress = false;
                      _cropApplyTimer?.cancel();
                      _savingCrop = false;
                    }),
                    itemBuilder: (context, pageIndex) {
                      final item = pages[pageIndex];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_cropPageId == item.id &&
                                  _cropImage != null &&
                                  _cropController != null)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Crop(
                                    key: ValueKey(_cropPageId),
                                    image: _cropImage!,
                                    controller: _cropController!,
                                    initialRectBuilder:
                                        InitialRectBuilder.withBuilder(
                                          (_, imageRect) => imageRect,
                                        ),
                                    interactive: false,
                                    clipBehavior: Clip.none,
                                    cornerDotBuilder: (size, edge) =>
                                        const DotControl(
                                          color: Color(0xff22b8a7),
                                        ),
                                    maskColor: Colors.black.withValues(
                                      alpha: 0.55,
                                    ),
                                    onMoved: (_, _) {
                                      if (_cropReady) _scheduleCropApply();
                                    },
                                    onStatusChanged: (status) {
                                      if (status == CropStatus.ready) {
                                        _cropReady = true;
                                      } else if (status ==
                                              CropStatus.cropping ||
                                          status == CropStatus.loading) {
                                        _cropReady = false;
                                      }
                                    },
                                    onCropped: (result) =>
                                        _handleCropResult(item, result),
                                  ),
                                )
                              else
                                Center(
                                  child: FutureBuilder<Uint8List>(
                                    key: ValueKey(
                                      '${item.id}:${item.cropPath}:${item.rotation}:${item.filter}',
                                    ),
                                    future: ref
                                        .read(imageProcessingProvider)
                                        .render(
                                          item.cropPath ?? item.imagePath,
                                          rotation: item.rotation,
                                          filter: item.filter,
                                          quality: 76,
                                          maxWidth: 1500,
                                        ),
                                    builder: (context, result) => result.hasData
                                        ? SizedBox.expand(
                                            child: InteractiveViewer(
                                              minScale: 0.75,
                                              maxScale: 4,
                                              child: Image.memory(
                                                result.data!,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.contain,
                                                gaplessPlayback: true,
                                              ),
                                            ),
                                          )
                                        : result.hasError
                                        ? Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Text(
                                              'Image preview failed: ${result.error}',
                                            ),
                                          )
                                        : const CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 88,
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    itemCount: pages.length,
                    onReorderItem: (oldIndex, newIndex) async {
                      final reordered = [...pages];
                      final moved = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, moved);
                      await db.reorderPages(
                        widget.documentId,
                        reordered.map((p) => p.id).toList(),
                      );
                      setState(() => _selectedPageId = moved.id);
                    },
                    itemBuilder: (context, pageIndex) {
                      final item = pages[pageIndex];
                      final selected = item.id == page.id;
                      return Padding(
                        key: ValueKey(item.id),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedPageId = item.id);
                            _pageController.animateToPage(
                              pageIndex,
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          child: Container(
                            width: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(item.cropPath ?? item.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const ColoredBox(color: Colors.black12),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 20,
                                    color: Colors.black54,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${pageIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _EditorToolbar(
                  filter: page.filter,
                  onRotateLeft: () => db.rotatePage(page.id, 270),
                  onRotateRight: () => db.rotatePage(page.id, 90),
                  onAutoCrop: () => _autoCrop(page),
                  onResetCrop: page.cropPath == null
                      ? null
                      : () => _resetCrop(page),
                  onFilter: (filter) => db.setPageFilter(page.id, filter),
                  onDuplicate: () => _duplicate(page, pages.length),
                  onDelete: () => _deletePage(page, pages.length),
                  onExport: () => _export(pages),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addPage(int pageCount) async {
    try {
      final photos = await ImagePicker().pickMultiImage(
        imageQuality: 100,
        maxWidth: 4800,
        maxHeight: 4800,
      );
      for (final photo in photos) {
        final bytes = await File(photo.path).readAsBytes();
        final path = await ref
            .read(scanStorageProvider)
            .savePage(widget.documentId, bytes);
        await ref
            .read(databaseProvider)
            .addPage(
              id: const Uuid().v4(),
              documentId: widget.documentId,
              imagePath: path,
              pageIndex: pageCount++,
            );
      }
    } catch (error) {
      _notify('Could not add this page. $error');
    }
  }

  Future<void> _duplicate(ScanPage page, int pageCount) async {
    try {
      final bytes = await File(page.cropPath ?? page.imagePath).readAsBytes();
      final path = await ref
          .read(scanStorageProvider)
          .savePage(widget.documentId, bytes);
      await ref
          .read(databaseProvider)
          .addPage(
            id: const Uuid().v4(),
            documentId: widget.documentId,
            imagePath: path,
            pageIndex: pageCount,
          );
      _notify('Page duplicated.');
    } catch (error) {
      _notify('Could not duplicate this page. $error');
    }
  }

  Future<void> _deletePage(ScanPage page, int pageCount) async {
    if (pageCount == 1) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove the last page?'),
          content: const Text(
            'This will delete the scan and its source image.',
          ),
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
      if (confirmed != true) return;
      await ref.read(databaseProvider).moveToTrash(widget.documentId);
      if (mounted) context.go('/');
      return;
    }
    await ref.read(databaseProvider).deletePage(page.id);
    if (await File(page.imagePath).exists()) {
      await File(page.imagePath).delete();
    }
    final crop = page.cropPath;
    if (crop != null && await File(crop).exists()) await File(crop).delete();
  }

  Future<void> _loadCropPreview(ScanPage page, String sourceKey) async {
    if (_loadingCropSourceKey != null) {
      if (_loadingCropSourceKey == sourceKey) {
        _queuedCropPage = null;
        _queuedCropSourceKey = null;
      } else {
        _queuedCropPage = page;
        _queuedCropSourceKey = sourceKey;
      }
      return;
    }
    _loadingCropSourceKey = sourceKey;
    _cropReady = false;
    _cropApplyTimer?.cancel();
    try {
      final path = page.cropPath ?? page.imagePath;
      final source = await ref
          .read(imageProcessingProvider)
          .render(
            path,
            rotation: page.rotation,
            filter: 'original',
            quality: 94,
            maxWidth: 2400,
          );
      if (!mounted || (_selectedPageId != null && _selectedPageId != page.id)) {
        return;
      }
      setState(() {
        _cropPageId = page.id;
        _cropSourceKey = sourceKey;
        _cropImage = source;
        _cropController = CropController();
        _cropAutoApplyInProgress = false;
      });
    } catch (error) {
      _notify('Could not open crop preview. $error');
    } finally {
      if (_loadingCropSourceKey == sourceKey) {
        _loadingCropSourceKey = null;
      }
      final queuedPage = _queuedCropPage;
      final queuedSourceKey = _queuedCropSourceKey;
      _queuedCropPage = null;
      _queuedCropSourceKey = null;
      if (mounted &&
          queuedPage != null &&
          queuedSourceKey != null &&
          queuedPage.id == _selectedPageId) {
        unawaited(_loadCropPreview(queuedPage, queuedSourceKey));
      }
    }
  }

  void _scheduleCropApply() {
    _cropApplyTimer?.cancel();
    _cropApplyTimer = Timer(const Duration(milliseconds: 550), () {
      if (!mounted ||
          !_cropReady ||
          _savingCrop ||
          _cropAutoApplyInProgress ||
          _cropController == null) {
        return;
      }
      _cropAutoApplyInProgress = true;
      _cropReady = false;
      setState(() => _savingCrop = true);
      _cropController!.crop();
    });
  }

  Future<void> _handleCropResult(ScanPage page, CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        setState(() => _savingCrop = true);
        try {
          final decoded = await ref
              .read(imageProcessingProvider)
              .decodeDimensions(croppedImage);
          if (decoded.$1 < 80 || decoded.$2 < 80) {
            throw const FormatException('The selected crop is too small.');
          }
          final newPath = await ref
              .read(scanStorageProvider)
              .savePage(widget.documentId, croppedImage);
          await ref.read(databaseProvider).setPageCrop(page.id, newPath);
          if (page.cropPath != null && await File(page.cropPath!).exists()) {
            await File(page.cropPath!).delete();
          }
          if (!mounted) return;
          setState(() {
            _cropSourceKey = '${page.id}:$newPath:0';
            _cropAutoApplyInProgress = false;
            _savingCrop = false;
          });
        } catch (error) {
          if (mounted) {
            setState(() {
              _cropAutoApplyInProgress = false;
              _savingCrop = false;
            });
            _cropReady = true;
          }
          _notify('Could not crop this page. $error');
        }
      case CropFailure(:final cause):
        _cropAutoApplyInProgress = false;
        if (mounted) {
          setState(() => _savingCrop = false);
          _cropReady = true;
        }
        _notify('Could not crop this page. $cause');
    }
  }

  Future<void> _autoCrop(ScanPage page) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Finding page edges…')),
      );
      final source = await ref
          .read(imageProcessingProvider)
          .render(
            page.cropPath ?? page.imagePath,
            rotation: page.rotation,
            filter: 'original',
            quality: 94,
            maxWidth: 2400,
          );
      final corrected = await ref.read(edgeCorrectionProvider).correct(source);
      if (corrected == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No document edges found. Adjust the crop manually.'),
          ),
        );
        return;
      }
      final path = await ref
          .read(scanStorageProvider)
          .savePage(widget.documentId, corrected);
      await ref.read(databaseProvider).setPageCrop(page.id, path);
      if (mounted && _selectedPageId == page.id) {
        setState(() {
          _cropSourceKey = '${page.id}:$path:0';
          _cropPageId = page.id;
          _cropImage = corrected;
          _cropController = CropController();
        });
      }
      final previousCrop = page.cropPath;
      if (previousCrop != null && await File(previousCrop).exists()) {
        await File(previousCrop).delete();
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not correct page edges. $error')),
      );
    }
  }

  Future<void> _resetCrop(ScanPage page) async {
    final crop = page.cropPath;
    await ref.read(databaseProvider).setPageCrop(page.id, null);
    if (crop != null && await File(crop).exists()) await File(crop).delete();
  }

  Future<void> _export(List<ScanPage> pages) async {
    var progressOpen = false;
    try {
      progressOpen = true;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Creating your PDF…')),
            ],
          ),
        ),
      );
      final document =
          await (ref
                  .read(databaseProvider)
                  .select(ref.read(databaseProvider).documents)
                ..where((d) => d.id.equals(widget.documentId)))
              .getSingle();
      final searchable = pages.any((page) => page.ocrText.trim().isNotEmpty);
      await ref
          .read(pdfServiceProvider)
          .createDocument(
            ref.read(databaseProvider),
            document,
            pages,
            searchable: searchable,
          );
      if (!mounted) return;
      if (progressOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        progressOpen = false;
      }
      final messenger = ScaffoldMessenger.of(context);
      context.go('/');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('PDF generated and added to your library.'),
        ),
      );
    } catch (error) {
      if (progressOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _notify('Could not create the PDF. $error');
    }
  }

  void _notify(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.filter,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onAutoCrop,
    required this.onResetCrop,
    required this.onFilter,
    required this.onDuplicate,
    required this.onDelete,
    required this.onExport,
  });
  final String filter;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onAutoCrop;
  final VoidCallback? onResetCrop;
  final ValueChanged<String> onFilter;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ToolButton(
                icon: Icons.auto_fix_high_outlined,
                label: 'Auto crop',
                onTap: onAutoCrop,
              ),
              if (onResetCrop != null)
                _ToolButton(
                  icon: Icons.crop_free,
                  label: 'Reset crop',
                  onTap: onResetCrop!,
                ),
              _ToolButton(
                icon: Icons.rotate_left,
                label: 'Rotate left',
                onTap: onRotateLeft,
              ),
              _ToolButton(
                icon: Icons.rotate_right,
                label: 'Rotate',
                onTap: onRotateRight,
              ),
              _ToolButton(
                icon: Icons.filter_b_and_w,
                label: 'Filter · ${filter.capitalize()}',
                onTap: () => _chooseFilter(context),
              ),
              _ToolButton(
                icon: Icons.copy_outlined,
                label: 'Duplicate',
                onTap: onDuplicate,
              ),
              _ToolButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                onTap: onDelete,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Create PDF'),
          ),
        ),
      ],
    ),
  );

  Future<void> _chooseFilter(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Image filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            for (final filter in ImageProcessing.filters)
              ListTile(
                leading: Icon(
                  filter == this.filter
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(filter.capitalize()),
                onTap: () => Navigator.pop(context, filter),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected != null) onFilter(selected);
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 76,
        height: 67,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    ),
  );
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
