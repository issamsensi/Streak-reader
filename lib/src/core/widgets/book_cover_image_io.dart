import 'dart:io';

import 'package:flutter/material.dart';

/// Local cover image on platforms with a file system.
Widget bookCoverImage({
  required String path,
  required double width,
  required double height,
  required Widget fallback,
}) =>
    Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
