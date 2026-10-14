import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'pdf_compression_level.dart';

class LocalPdfOutput {
  const LocalPdfOutput({
    required this.path,
    required this.fileName,
    required this.originalBytes,
    required this.compressedBytes,
  });

  final String path;
  final String fileName;
  final int originalBytes;
  final int compressedBytes;
}

class LocalPdfOperations {
  Future<String> merge(List<PlatformFile> files) async {
    if (files.length < 2) {
      throw ArgumentError('Select at least two PDF files to merge.');
    }
    final output = pw.Document(title: 'Merged PDF', author: 'ScanFlow');
    for (final file in files) {
      final sourceBytes = await file.readAsBytes();
      await for (final raster in Printing.raster(sourceBytes, dpi: 144)) {
        final encoded = await compute(_encodeRaster, {
          'pixels': raster.pixels,
          'width': raster.width,
          'height': raster.height,
          'quality': 90,
          'maxWidth': null,
        });
        _addPage(
          output,
          encoded['bytes']! as Uint8List,
          encoded['width']! as int,
          encoded['height']! as int,
        );
      }
    }
    return _writeOutput(output, 'ScanFlow-merged.pdf');
  }

  Future<List<LocalPdfOutput>> compress(
    List<PlatformFile> files, {
    required PdfCompressionLevel level,
  }) async {
    final results = <LocalPdfOutput>[];
    for (final file in files) {
      final sourceBytes = await file.readAsBytes();
      final sourceSize = sourceBytes.length;
      final outputName =
          '${p.basenameWithoutExtension(file.name)}-compressed.pdf';
      Uint8List? bestBytes;
      for (final profile in level.profiles) {
        final candidate = await _compressPass(
          sourceBytes,
          title: p.basenameWithoutExtension(file.name),
          profile: profile,
        );
        if (bestBytes == null || candidate.length < bestBytes.length) {
          bestBytes = candidate;
        }
        if (level != PdfCompressionLevel.extreme &&
            bestBytes.length <= sourceSize * level.targetSizeRatio) {
          break;
        }
      }
      final outputPath = await _writeOutputBytes(bestBytes!, outputName);
      results.add(
        LocalPdfOutput(
          path: outputPath,
          fileName: outputName,
          originalBytes: sourceSize,
          compressedBytes: await File(outputPath).length(),
        ),
      );
    }
    return results;
  }

  Future<Uint8List> _compressPass(
    Uint8List sourceBytes, {
    required String title,
    required PdfCompressionProfile profile,
  }) async {
    final output = pw.Document(title: title, author: 'ScanFlow');
    await for (final raster in Printing.raster(
      sourceBytes,
      dpi: profile.dpi.toDouble(),
    )) {
      final encoded = await compute(_encodeRaster, {
        'pixels': raster.pixels,
        'width': raster.width,
        'height': raster.height,
        'quality': profile.quality,
        'maxWidth': profile.maxWidth,
      });
      _addPage(
        output,
        encoded['bytes']! as Uint8List,
        encoded['width']! as int,
        encoded['height']! as int,
      );
    }
    return Uint8List.fromList(await output.save());
  }

  void _addPage(pw.Document output, Uint8List bytes, int width, int height) {
    final pageWidth = 595.0;
    final pageHeight = pageWidth * height / width;
    final image = pw.MemoryImage(bytes);
    output.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, pageHeight, marginAll: 0),
        margin: pw.EdgeInsets.zero,
        clip: true,
        build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
      ),
    );
  }

  Future<String> _writeOutput(pw.Document document, String fileName) async {
    return _writeOutputBytes(await document.save(), fileName);
  }

  Future<String> _writeOutputBytes(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final path = p.join(
      directory.path,
      'scanflow-${DateTime.now().microsecondsSinceEpoch}-$fileName',
    );
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }
}

Map<String, Object> _encodeRaster(Map<String, Object?> arguments) {
  final width = arguments['width']! as int;
  final height = arguments['height']! as int;
  final pixels = arguments['pixels']! as Uint8List;
  final decoded = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: pixels.buffer,
    bytesOffset: pixels.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  final maxWidth = arguments['maxWidth'] as int?;
  final image = maxWidth != null && decoded.width > maxWidth
      ? img.copyResize(
          decoded,
          width: maxWidth,
          interpolation: img.Interpolation.average,
        )
      : decoded;
  return {
    'bytes': Uint8List.fromList(
      img.encodeJpg(image, quality: arguments['quality']! as int),
    ),
    'width': image.width,
    'height': image.height,
  };
}
