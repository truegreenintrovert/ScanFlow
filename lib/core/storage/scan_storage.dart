import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ScanStorage {
  static const _uuid = Uuid();

  Future<Directory> documentDirectory(String documentId) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'scans', documentId));
    await directory.create(recursive: true);
    return directory;
  }

  Future<String> savePage(String documentId, List<int> bytes) async {
    final directory = await documentDirectory(documentId);
    final path = p.join(directory.path, 'page_${_uuid.v4()}.jpg');
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<String> pdfPath(String documentId) async {
    final directory = await documentDirectory(documentId);
    return p.join(directory.path, 'scanflow.pdf');
  }

  Future<String> compressedPdfPath(String documentId) async {
    final directory = await documentDirectory(documentId);
    return p.join(directory.path, 'scanflow-compressed.pdf');
  }

  Future<void> removeDocumentAssets(String documentId) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'scans', documentId));
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
