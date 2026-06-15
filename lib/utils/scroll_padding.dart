import 'package:flutter/material.dart';

/// Padding inferior consistente — respeita barra do sistema e bottom nav do app.
class ScrollBottomPadding {
  ScrollBottomPadding._();

  /// Inset inferior real do dispositivo (gestos ou 3 botões).
  static double systemBottom(BuildContext context) {
    final mq = MediaQuery.of(context);
    final v = mq.viewPadding.bottom;
    if (v > 0) return v;
    return mq.padding.bottom > 0 ? mq.padding.bottom : 32;
  }

  static double bottom(BuildContext context, {double extra = 16, bool includeNavBar = false}) {
    var pad = systemBottom(context) + extra;
    if (includeNavBar) pad += kBottomNavigationBarHeight;
    return pad;
  }

  static EdgeInsets all(BuildContext context, {double extra = 16, bool includeNavBar = false}) {
    return EdgeInsets.fromLTRB(16, 16, 16, bottom(context, extra: extra, includeNavBar: includeNavBar));
  }

  static EdgeInsets onlyBottom(BuildContext context, {double extra = 16, bool includeNavBar = false}) {
    return EdgeInsets.only(bottom: bottom(context, extra: extra, includeNavBar: includeNavBar));
  }
}
