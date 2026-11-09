import 'dart:convert';
import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

import 'pdf_bytes.dart';

/// Counts the pages of a PDF without rendering it.
///
/// Returns `null` when no usable source is given or the document cannot
/// be opened (missing/corrupt/encrypted file), so callers can fall back
/// to a manually entered page count instead of failing.
typedef PdfPageCounter = Future<int?> Function({
  String? filePath,
  Uint8List? bytes,
  String? sourceName,
});

Future<int?> countPdfPages({
  String? filePath,
  Uint8List? bytes,
  String? sourceName,
}) async {
  final counted = await _countWithPdfrx(
    filePath: filePath,
    bytes: bytes,
    sourceName: sourceName,
  );
  if (counted != null) return counted;

  // Fallback for environments where the native pdfium engine is
  // unavailable (e.g. flutter_tester) or a file cannot be opened by
  // path: estimate the count from the raw bytes.
  final raw = bytes ??
      (filePath != null && filePath.isNotEmpty
          ? await readLocalFileBytes(filePath)
          : null);
  return raw == null ? null : pdfPageCountFromBytes(raw);
}

Future<int?> _countWithPdfrx({
  String? filePath,
  Uint8List? bytes,
  String? sourceName,
}) async {
  PdfDocument? document;
  try {
    if (filePath != null && filePath.isNotEmpty) {
      document = await PdfDocument.openFile(filePath);
    } else if (bytes != null && bytes.isNotEmpty) {
      document = await PdfDocument.openData(bytes, sourceName: sourceName);
    } else {
      return null;
    }
    final count = document.pages.length;
    return count > 0 ? count : null;
  } catch (_) {
    return null;
  } finally {
    await document?.dispose();
  }
}

/// Best-effort page count from raw PDF bytes.
///
/// Reads the `/Count` of the page tree (the root node's count is the
/// document total, so the largest one wins) and falls back to counting
/// `/Type /Page` dictionaries. Returns `null` when neither is present,
/// e.g. when page objects live in compressed object streams.
int? pdfPageCountFromBytes(Uint8List bytes) {
  if (bytes.isEmpty) return null;
  final text = latin1.decode(bytes, allowInvalid: true);

  var best = 0;
  for (final match in RegExp(r'/Count\s+(\d+)').allMatches(text)) {
    final value = int.tryParse(match.group(1)!) ?? 0;
    if (value > best) best = value;
  }
  if (best > 0) return best;

  final pages = RegExp(r'/Type\s*/Page(?![s\w])').allMatches(text).length;
  return pages > 0 ? pages : null;
}
