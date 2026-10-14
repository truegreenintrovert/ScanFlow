import 'package:flutter/services.dart';

class PdfFileActions {
  static const _channel = MethodChannel('scanflow/pdf_files');

  Future<bool> saveToDevice(String path, String fileName) async =>
      await _channel.invokeMethod<bool>('savePdfToDevice', {
        'path': path,
        'fileName': fileName,
      }) ??
      false;

  Future<String?> saveToDownloads(String path, String fileName) =>
      _channel.invokeMethod<String>('savePdfToDownloads', {
        'path': path,
        'fileName': fileName,
      });

  Future<void> share(String path, String title) =>
      _channel.invokeMethod<void>('sharePdf', {'path': path, 'title': title});
}
