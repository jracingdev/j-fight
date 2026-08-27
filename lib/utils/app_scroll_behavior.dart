import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Scroll com mouse/trackpad na web (Flutter desativa drag de mouse por padrão).
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
