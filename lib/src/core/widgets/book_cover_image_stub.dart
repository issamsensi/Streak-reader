import 'package:flutter/material.dart';

/// On web a stored local path is not readable; keep the gradient cover.
Widget bookCoverImage({
  required String path,
  required double width,
  required double height,
  required Widget fallback,
}) =>
    fallback;
