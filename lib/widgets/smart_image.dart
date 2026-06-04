import 'package:flutter/material.dart';
import '../utils/image_utils.dart';

/// Exibe imagem de URL, blob: ou path local — funciona em Android e Web
class SmartImage extends StatelessWidget {
  final String? path;
  final double? width, height;
  final BoxFit fit;
  final Widget? placeholder;

  const SmartImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) return _ph();
    return SizedBox(
      width: width, height: height,
      child: imageWidgetFromPath(path!, fit: fit, errorWidget: _ph()),
    );
  }

  Widget _ph() => Container(
    width: width, height: height,
    color: Colors.grey.shade100,
    child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
  );
}

/// ImageProvider multiplataforma
ImageProvider smartImageProvider(String path) => imageProviderFromPath(path);
