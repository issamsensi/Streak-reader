import 'dart:typed_data';

/// On web there is no local file to read; PDFs arrive as bytes instead.
Future<Uint8List?> readLocalFileBytes(String path) async => null;
