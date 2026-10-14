import 'package:flutter/services.dart';

class DocumentEdgeCorrection {
  static const _channel = MethodChannel('scanflow/document_edges');

  Future<Uint8List?> correct(Uint8List encodedImage) =>
      _channel.invokeMethod<Uint8List>('autoCorrect', encodedImage);
}
