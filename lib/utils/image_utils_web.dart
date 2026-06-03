import 'package:flutter/material.dart';

/// Web: todos os caminhos tratados como URL (blob: ou http:)
ImageProvider imageProviderFromPath(String path) => NetworkImage(path);

/// Web: usa Image.network para tudo (blob: URLs funcionam)
Widget imageWidgetFromPath(String path, {BoxFit fit = BoxFit.cover, Widget? errorWidget}) {
  return Image.network(path, fit: fit,
      errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox());
}
