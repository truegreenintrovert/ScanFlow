import 'dart:convert';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  const OcrResult({required this.text, required this.boxes});

  final String text;
  final List<Map<String, Object>> boxes;
}

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<OcrResult> recognize(String path) async {
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(path),
    );
    final boxes = <Map<String, Object>>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final rect = line.boundingBox;
        boxes.add({
          'text': line.text,
          'left': rect.left,
          'top': rect.top,
          'width': rect.width,
          'height': rect.height,
        });
      }
    }
    return OcrResult(text: result.text, boxes: boxes);
  }

  String encodeBoxes(List<Map<String, Object>> boxes) => jsonEncode(boxes);

  Future<void> dispose() => _recognizer.close();
}
