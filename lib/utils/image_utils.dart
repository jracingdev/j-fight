// Exporta implementação correta por plataforma
// Mobile (dart:io disponível) → image_utils_mobile.dart
// Web (dart:html) → image_utils_web.dart
export 'image_utils_mobile.dart'
    if (dart.library.html) 'image_utils_web.dart';
