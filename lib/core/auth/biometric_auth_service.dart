import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

const _kBiometricEnabled = 'biometric_enabled';
const _kBiometricEmail = 'biometric_email';
const _kBiometricPassword = 'biometric_password';

/// Login biométrico: credenciais guardadas após login com senha bem-sucedido.
class BiometricAuthService {
  static final BiometricAuthService instance = BiometricAuthService._();
  BiometricAuthService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final _localAuth = LocalAuthentication();

  Future<bool> get dispositivoSuporta async {
    if (kIsWeb) return false;
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('biometric isDeviceSupported: $e');
      return false;
    }
  }

  /// Sensor/PIN do aparelho disponível (critério amplo — evita falso negativo em Motorola etc.).
  Future<bool> get biometriaDisponivel async {
    if (kIsWeb) return false;
    try {
      if (!await dispositivoSuporta) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      if (canCheck) return true;
      final tipos = await _localAuth.getAvailableBiometrics();
      return tipos.isNotEmpty || await dispositivoSuporta;
    } catch (e) {
      debugPrint('biometric canCheck: $e');
      return await dispositivoSuporta;
    }
  }

  Future<bool> get habilitado async {
    final v = await _storage.read(key: _kBiometricEnabled);
    return v == 'true';
  }

  Future<void> habilitar({required String email, required String senha}) async {
    await _storage.write(key: _kBiometricEnabled, value: 'true');
    await _storage.write(key: _kBiometricEmail, value: email.trim());
    await _storage.write(key: _kBiometricPassword, value: senha);
  }

  Future<void> desabilitar() async {
    await _storage.delete(key: _kBiometricEnabled);
    await _storage.delete(key: _kBiometricEmail);
    await _storage.delete(key: _kBiometricPassword);
  }

  Future<({String email, String senha})?> lerCredenciais() async {
    if (!await habilitado) return null;
    final email = await _storage.read(key: _kBiometricEmail);
    final senha = await _storage.read(key: _kBiometricPassword);
    if (email == null || senha == null || email.isEmpty) return null;
    return (email: email, senha: senha);
  }

  Future<bool> autenticarBiometria() async {
    if (kIsWeb) return false;
    try {
      if (!await biometriaDisponivel) return false;
      return await _localAuth.authenticate(
        localizedReason: 'Use sua digital ou rosto para entrar no J FIGHT',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('autenticarBiometria: $e');
      return false;
    }
  }
}
