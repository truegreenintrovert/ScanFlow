import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/scanflow_navigation_bar.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});
  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  late final String _documentId;
  int _pageCount = 0;
  int _flashIndex = 0;
  bool _busy = false;
  bool _started = false;
  bool _initializing = false;
  static const _flashModes = [FlashMode.auto, FlashMode.always, FlashMode.off];
  static const _flashLabels = ['Auto', 'On', 'Off'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _documentId = const Uuid().v4();
    _start();
  }

  Future<void> _start() async {
    if (_initializing) return;
    _initializing = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
          'NoCamera',
          'No camera is available on this device.',
        );
      }
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(_flashModes[_flashIndex]);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyCameraError(error));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Camera could not be started. $error');
    } finally {
      _initializing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _start();
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_busy || controller == null || !controller.value.isInitialized) return;
    setState(() => _busy = true);
    try {
      final photo = await controller.takePicture();
      await _addPage(await File(photo.path).readAsBytes());
    } on CameraException catch (error) {
      _notify(_friendlyCameraError(error));
    } catch (error) {
      _notify('Could not save this page. $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importImages() async {
    try {
      final images = await ImagePicker().pickMultiImage(
        imageQuality: 100,
        maxWidth: 4800,
        maxHeight: 4800,
      );
      for (final image in images) {
        await _addPage(await File(image.path).readAsBytes());
      }
    } catch (error) {
      _notify('Could not import the selected image. $error');
    }
  }

  Future<void> _addPage(List<int> bytes) async {
    if (!_started) {
      final now = DateTime.now();
      final title =
          'Scan ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      await ref
          .read(databaseProvider)
          .createDocument(id: _documentId, title: title);
      _started = true;
    }
    final path = await ref
        .read(scanStorageProvider)
        .savePage(_documentId, bytes);
    await ref
        .read(databaseProvider)
        .addPage(
          id: const Uuid().v4(),
          documentId: _documentId,
          imagePath: path,
          pageIndex: _pageCount,
        );
    if (mounted) setState(() => _pageCount++);
  }

  Future<void> _toggleFlash() async {
    final nextIndex = (_flashIndex + 1) % _flashModes.length;
    setState(() => _flashIndex = nextIndex);
    try {
      await _controller?.setFlashMode(_flashModes[nextIndex]);
    } on CameraException {
      setState(() => _flashIndex = 2);
      _notify('Flash control is not available.');
    }
  }

  Future<void> _finish() async {
    if (_pageCount == 0) {
      _notify('Capture or import at least one page first.');
      return;
    }
    await _controller?.dispose();
    _controller = null;
    if (mounted) context.go('/edit/$_documentId');
  }

  Future<void> _cancel() async {
    await _controller?.dispose();
    _controller = null;
    if (_started) {
      await ref.read(databaseProvider).deleteDocument(_documentId);
      await ref.read(scanStorageProvider).removeDocumentAssets(_documentId);
    }
    if (mounted) context.go('/');
  }

  Future<void> _selectMainTab(int index) async {
    if (index == 1 || _busy) return;
    if (_pageCount > 0) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard this scan?'),
          content: const Text(
            'The pages captured in this session will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep scanning'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (discard != true) return;
    }
    await _controller?.dispose();
    _controller = null;
    if (_started) {
      await ref.read(databaseProvider).deleteDocument(_documentId);
      await ref.read(scanStorageProvider).removeDocumentAssets(_documentId);
    }
    if (mounted) context.go(index == 0 ? '/' : '/history');
  }

  void _notify(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: const Color(0xff08100f),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _cancel();
        },
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: _error != null
                    ? _CameraError(message: _error!, onGallery: _importImages)
                    : controller == null || !controller.value.isInitialized
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) => GestureDetector(
                          onTapDown: (details) => controller.setFocusPoint(
                            Offset(
                              details.localPosition.dx / constraints.maxWidth,
                              details.localPosition.dy / constraints.maxHeight,
                            ),
                          ),
                          child: CameraPreview(controller),
                        ),
                      ),
              ),
              Positioned(
                left: 12,
                right: 12,
                top: 6,
                child: Row(
                  children: [
                    _RoundControl(
                      icon: Icons.close,
                      tooltip: 'Discard scan',
                      onTap: _cancel,
                    ),
                    const Spacer(),
                    if (_pageCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '$_pageCount ${_pageCount == 1 ? 'page' : 'pages'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    _RoundControl(
                      icon: _flashIcon(_flashModes[_flashIndex]),
                      tooltip: 'Flash: ${_flashLabels[_flashIndex]}',
                      onTap: _toggleFlash,
                      label: _flashLabels[_flashIndex],
                    ),
                  ],
                ),
              ),
              if (_error == null)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 26,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Keep the page flat and well lit',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _RoundControl(
                                icon: Icons.photo_library_outlined,
                                tooltip: 'Add from gallery',
                                onTap: _importImages,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _busy ? null : _capture,
                            child: Container(
                              width: 76,
                              height: 76,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _busy ? Colors.white54 : Colors.white,
                                ),
                                child: _busy
                                    ? const Padding(
                                        padding: EdgeInsets.all(23),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _RoundControl(
                                icon: Icons.check_rounded,
                                tooltip: 'Review pages',
                                onTap: _finish,
                                label: 'Done',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ScanFlowNavigationBar(
        currentIndex: 1,
        onDestinationSelected: _selectMainTab,
      ),
    );
  }
}

String _friendlyCameraError(CameraException error) => switch (error.code) {
  'CameraAccessDenied' => 'Camera permission was denied. Allow camera access in Android settings, or import a photo instead.',
  'CameraAccessDeniedWithoutPrompt' => 'Camera access is disabled. Allow it in Android settings, or import a photo instead.',
  'NoCamera' =>
    'No camera is available. You can still import photos from the gallery.',
  _ =>
    '${error.description ?? 'The camera is unavailable.'} You can still import photos from the gallery.',
};

IconData _flashIcon(FlashMode mode) => switch (mode) {
  FlashMode.auto => Icons.flash_auto_rounded,
  FlashMode.always => Icons.flash_on_rounded,
  _ => Icons.flash_off_rounded,
};

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.label,
  });
  final IconData icon;
  final String tooltip;
  final String? label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        constraints: const BoxConstraints(minWidth: 46, minHeight: 46),
        padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: Icon(icon, color: Colors.white),
            ),
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.message, required this.onGallery});
  final String message;
  final VoidCallback onGallery;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_photography_outlined,
            color: Colors.white70,
            size: 54,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose photos'),
          ),
        ],
      ),
    ),
  );
}
