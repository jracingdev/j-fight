import 'dart:typed_data';
import 'package:flutter/material.dart';

bool _isValidUrl(String path) =>
    path.startsWith('http://') ||
    path.startsWith('https://') ||
    path.startsWith('blob:');

// GIF transparente 1x1 pixel como Uint8List
final _kTransparentPixel = Uint8List.fromList([
  0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00,
  0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x21, 0xf9, 0x04, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00,
  0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3b,
]);

/// Web: só URLs válidas funcionam
/// Paths locais do Android são IGNORADOS completamente — sem crash
ImageProvider imageProviderFromPath(String path) {
  if (!_isValidUrl(path)) {
    return MemoryImage(_kTransparentPixel);
  }
  return NetworkImage(path);
}

Widget imageWidgetFromPath(String path, {BoxFit fit = BoxFit.cover, Widget? errorWidget}) {
  if (!_isValidUrl(path)) return errorWidget ?? const SizedBox();
  return Image.network(
    path,
    fit: fit,
    errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox(),
  );
}
