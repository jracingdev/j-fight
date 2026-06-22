import 'dart:io';
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

  final ext = extension == 'jpeg' ? 'jpg' : extension;

  try {
    Uint8List? data = bytes;
    if ((data == null || data.isEmpty) && localPath != null) {
      final file = File(localPath);
      if (!await file.exists()) return urlAtual;
      data = await file.readAsBytes();
    }
    if (data == null || data.isEmpty) return urlAtual;

    return ApiClient.instance.uploadFoto(pasta: pasta, bytes: data, extension: ext);
  } catch (e) {
    debugPrint('uploadFotoBucket: $e');
    return null;
  }
}
