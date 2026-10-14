import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

class ImageProcessing {
  static const filters = [
    'original',
    'auto enhance',
    'color enhance',
    'grayscale',
    'black & white',
    'high contrast',
  ];

  Future<Uint8List> render(
    String path, {
    required int rotation,
    required String filter,
    int quality = 92,
    int? maxWidth,
  }) async {
    final bytes = Uint8List.fromList(await File(path).readAsBytes());
    return compute(_renderImage, {
      'bytes': bytes,
      'rotation': rotation,
      'filter': filter,
      'quality': quality,
      'maxWidth': maxWidth,
    });
  }

  Future<(int, int)> decodeDimensions(List<int> bytes) async {
    final dimensions = await compute(
      _decodeDimensions,
      Uint8List.fromList(bytes),
    );
    return (dimensions[0], dimensions[1]);
  }
}

Uint8List _renderImage(Map<String, Object?> arguments) {
  final source = img.decodeImage(arguments['bytes']! as Uint8List);
  if (source == null) {
    throw const FormatException('This image could not be decoded.');
  }
  var result = img.bakeOrientation(source);
  final rotation = arguments['rotation']! as int;
  if (rotation % 360 != 0) {
    result = img.copyRotate(result, angle: rotation % 360);
  }
  final maxWidth = arguments['maxWidth'] as int?;
  if (maxWidth != null && result.width > maxWidth) {
    result = img.copyResize(
      result,
      width: maxWidth,
      interpolation: img.Interpolation.average,
    );
  }
  switch (arguments['filter']! as String) {
    case 'auto enhance':
      img.normalize(result, min: 0, max: 255);
      img.adjustColor(
        result,
        contrast: 1.12,
        brightness: 1.02,
        saturation: 0.96,
      );
    case 'color enhance':
      img.normalize(result, min: 2, max: 253);
      img.adjustColor(
        result,
        contrast: 1.12,
        brightness: 1.025,
        saturation: 1.22,
      );
    case 'grayscale':
      img.grayscale(result);
    case 'black & white':
      img.grayscale(result);
      img.luminanceThreshold(result, threshold: 150);
    case 'high contrast':
      img.adjustColor(result, contrast: 1.65);
  }
  return Uint8List.fromList(
    img.encodeJpg(result, quality: arguments['quality']! as int),
  );
}

List<int> _decodeDimensions(Uint8List bytes) {
  final source = img.decodeImage(bytes);
  if (source == null) {
    throw const FormatException('This image could not be decoded.');
  }
  final oriented = img.bakeOrientation(source);
  return [oriented.width, oriented.height];
}
