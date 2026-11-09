import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:streak_reader/src/core/utils/pdf_page_count.dart';

Future<Uint8List> _makePdf(int pages) async {
  final doc = pw.Document();
  for (var i = 0; i < pages; i++) {
    doc.addPage(pw.Page(build: (_) => pw.Text('Page ${i + 1}')));
  }
  return doc.save();
}

void main() {
  test('returns null without a source', () async {
    expect(await countPdfPages(), isNull);
    expect(await countPdfPages(filePath: ''), isNull);
    expect(await countPdfPages(bytes: Uint8List(0)), isNull);
  });

  test('returns null for a missing file', () async {
    expect(await countPdfPages(filePath: '/no/such/book.pdf'), isNull);
  });

  test('returns null for bytes that are not a PDF', () async {
    expect(
      await countPdfPages(bytes: Uint8List.fromList('not a pdf'.codeUnits)),
      isNull,
    );
  });

  test('counts the pages of a real PDF from bytes', () async {
    final bytes = await _makePdf(3);
    expect(
      await countPdfPages(bytes: bytes, sourceName: 'three.pdf'),
      3,
    );
  });

  test('counts the pages of a real PDF from a file', () async {
    final dir = await Directory.systemTemp.createTemp();
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/two.pdf');
    await file.writeAsBytes(await _makePdf(2));
    expect(await countPdfPages(filePath: file.path), 2);
  });
}
