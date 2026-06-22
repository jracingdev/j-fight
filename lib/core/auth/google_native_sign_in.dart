import 'package:google_sign_in/google_sign_in.dart';

import '../app_platform.dart';
import 'oauth_config.dart';

/// Login Google nativo no Android/iOS — retorna idToken para a API.
class GoogleNativeSignIn {
  static bool _initialized = false;

  static bool get disponivel =>
      isNativeApp && OAuthConfig.googleWebClientId.trim().isNotEmpty;

  static Future<void> ensureInitialized() async {
    if (_initialized || !disponivel) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: OAuthConfig.googleWebClientId.trim(),
    );
    _initialized = true;
  }

  /// Retorna idToken em sucesso; null se o usuário cancelou.
  static Future<String?> signIn() async {
    if (!disponivel) return null;

    await ensureInitialized();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw StateError('Google authenticate não suportado nesta plataforma.');
    }

    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google não retornou idToken. Verifique o Web Client ID no Google Cloud.');
    }

    await account.authorizationClient
            .authorizationForScopes(const ['email', 'profile']) ??
        await account.authorizationClient.authorizeScopes(const ['email', 'profile']);

    return idToken;
  }
}
