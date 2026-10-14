import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/app_database.dart';
import '../storage/scan_storage.dart';
import 'image_processing.dart';
import 'pdf_compression_level.dart';

class PdfService {
  PdfService(this._storage, this._processing);

  final ScanStorage _storage;
  final ImageProcessing _processing;

  Future<String> createDocument(
    AppDatabase database,
    Document document,
    List<ScanPage> pages, {
    required bool searchable,
    int imageQuality = 92,
    int? maxImageWidth,
    String? destinationPath,
    bool saveToLibrary = true,
  }) async {
    if (pages.isEmpty) {
      throw StateError('Add at least one page before exporting.');
    }
    final pdf = pw.Document(title: document.title, author: 'ScanFlow');
    for (final page in pages) {
      final bytes = await _processing.render(
        page.cropPath ?? page.imagePath,
        rotation: page.rotation,
        filter: page.filter,
        quality: imageQuality,
        maxWidth: maxImageWidth,
      );
      final (imageWidth, imageHeight) = await _processing.decodeDimensions(
        bytes,
      );
      final pageWidth = 595.0;
      final pageHeight = pageWidth * imageHeight / imageWidth;
      final image = pw.MemoryImage(bytes);
      final overlays = <pw.Widget>[
        pw.Positioned.fill(child: pw.Image(image, fit: pw.BoxFit.fill)),
      ];
      if (searchable && page.ocrText.trim().isNotEmpty) {
        final boxes = (jsonDecode(page.ocrBoxes) as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final (sourceWidth, sourceHeight) = await _processing.decodeDimensions(
          await File(page.cropPath ?? page.imagePath).readAsBytes(),
        );
        for (final box in boxes) {
          var left = (box['left'] as num).toDouble();
          var top = (box['top'] as num).toDouble();
          var width = (box['width'] as num).toDouble();
          var height = (box['height'] as num).toDouble();
          switch (page.rotation % 360) {
            case 90:
              final oldLeft = left;
              left = sourceHeight - top - height;
              top = oldLeft;
              (width, height) = (height, width);
            case 180:
              left = sourceWidth - left - width;
              top = sourceHeight - top - height;
            case 270:
              final oldLeft = left;
              left = top;
              top = sourceWidth - oldLeft - width;
              (width, height) = (height, width);
          }
          final factorX = pageWidth / imageWidth;
          final factorY = pageHeight / imageHeight;
          final text = (box['text'] as String?) ?? '';
          if (text.trim().isEmpty) continue;
          overlays.add(
            pw.Positioned(
              left: left * factorX,
              top: top * factorY,
              child: pw.SizedBox(
                width: (width * factorX).clamp(1, pageWidth),
                height: (height * factorY).clamp(1, pageHeight),
                child: pw.Text(
                  text,
                  maxLines: 2,
                  style: pw.TextStyle(
                    fontSize: (height * factorY).clamp(4, 72),
                    color: const PdfColor(0, 0, 0),
                    renderingMode: PdfTextRenderingMode.invisible,
                  ),
                ),
              ),
            ),
          );
        }
      }
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, pageHeight, marginAll: 0),
          margin: pw.EdgeInsets.zero,
          clip: true,
          build: (_) => pw.Stack(children: overlays),
        ),
      );
    }
    final outputPath = destinationPath ?? await _storage.pdfPath(document.id);
    final tempPath = '$outputPath.tmp';
    final backupPath = '$outputPath.backup';
    await File(tempPath).writeAsBytes(await pdf.save(), flush: true);
    final output = File(outputPath);
    final backup = File(backupPath);
    if (await output.exists()) {
      if (await backup.exists()) await backup.delete();
      await output.rename(backupPath);
    }
    try {
      await File(tempPath).rename(outputPath);
      if (await backup.exists()) await backup.delete();
    } catch (_) {
      if (await backup.exists() && !await output.exists()) {
        await backup.rename(outputPath);
      }
      rethrow;
    }
    if (saveToLibrary) await database.savePdf(document.id, outputPath);
    return outputPath;
  }

  Future<String> createCompressedCopy(
    AppDatabase database,
    Document document,
    List<ScanPage> pages, {
    required bool searchable,
    required PdfCompressionLevel level,
  }) async {
    final outputPath = await _storage.compressedPdfPath(document.id);
    final originalPath = document.pdfPath;
    final originalSize =
        originalPath != null && await File(originalPath).exists()
        ? await File(originalPath).length()
        : 0;
    Uint8List? bestBytes;
    for (final profile in level.profiles) {
      // A page is 595 PDF points wide; convert the profile's DPI to pixels so
      // every mode actually reduces resolution, even when source scans are
      // already narrower than the profile's legacy maxWidth value.
      final widthAtDpi = (595 * profile.dpi / 72).round();
      final effectiveMaxWidth = profile.maxWidth < widthAtDpi
          ? profile.maxWidth
          : widthAtDpi;
      await createDocument(
        database,
        document,
        pages,
        searchable: searchable,
        imageQuality: profile.quality,
        maxImageWidth: effectiveMaxWidth,
        destinationPath: outputPath,
        saveToLibrary: false,
      );
      final candidate = await File(outputPath).readAsBytes();
      if (bestBytes == null || candidate.length < bestBytes.length) {
        bestBytes = candidate;
      }
      if (level != PdfCompressionLevel.extreme &&
          originalSize > 0 &&
          bestBytes.length <= originalSize * level.targetSizeRatio) {
        break;
      }
    }
    await File(outputPath).writeAsBytes(bestBytes!, flush: true);
    return outputPath;
  }
}
