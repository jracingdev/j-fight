import '../app_platform.dart';

/// URLs de retorno OAuth — cadastre todas no Supabase (Authentication → URL Configuration).
class OAuthConfig {
  static const webRedirect = 'https://jracingdev.github.io/smbjj/';

  /// Deep link do app Android (package com.smbijj.ct_sm_bjj).
  static const appRedirect = 'com.smbijj.ct_sm_bjj://login-callback';

  /// Legado Supabase Flutter (mantido no AndroidManifest).
  static const legacyRedirect = 'io.supabase.flutter://callback';

  static String get redirectUrl => isWebApp ? webRedirect : appRedirect;
}
