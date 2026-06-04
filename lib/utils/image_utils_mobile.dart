import 'dart:io';
import 'package:flutter/material.dart';

/// Cria ImageProvider a partir de path local (mobile) ou URL
ImageProvider imageProviderFromPath(String path) {
  if (path.startsWith('http')) return NetworkImage(path);
  return FileImage(File(path));
}

/// Cria widget de imagem a partir de path local (mobile) ou URL
Widget imageWidgetFromPath(String path, {BoxFit fit = BoxFit.cover, Widget? errorWidget}) {
  if (path.startsWith('http')) {
    return Image.network(path, fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox());
  }
  return Image.file(File(path), fit: fit,
      errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox());
}
