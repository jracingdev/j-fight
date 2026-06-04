import 'package:flutter/foundation.dart';

/// Web = GitHub Pages / navegador (iOS, desktop, etc.).
bool get isWebApp => kIsWeb;

/// App instalado (APK/IPA) — não é build web.
bool get isNativeApp =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
