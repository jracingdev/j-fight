import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'api/api_client.dart';

Future<String?> uploadFotoBucket({
  required String pasta,
  String? localPath,
  Uint8List? bytes,
  String extension = 'jpg',
  String? urlAtual,
}) async {
  if (localPath != null &&
      (localPath.startsWith('http://') || localPath.startsWith('https://'))) {
    return localPath;
  }

  if (bytes == null || bytes.isEmpty) {
    return urlAtual != null &&
            (urlAtual.startsWith('http://') || urlAtual.startsWith('https://'))
        ? urlAtual
        : null;
  }

  final ext = extension == 'jpeg' ? 'jpg' : extension;

  try {
    return ApiClient.instance.uploadFoto(pasta: pasta, bytes: bytes, extension: ext);
  } catch (e) {
    debugPrint('uploadFotoBucket web: $e');
    return null;
  }
}
