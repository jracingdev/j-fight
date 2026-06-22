import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLembrar = 'lembrar_credenciais';
const _kEmail = 'credencial_email_salvo';
const _kSenhaSecure = 'credencial_senha_salva';
const _kSenhaPrefs = 'credencial_senha_salva_prefs';

/// Guarda e-mail/senha localmente quando o usuário marca "Lembrar senha".
class CredentialRememberService {
  static final CredentialRememberService instance = CredentialRememberService._();
  CredentialRememberService._();

  final _secure = const FlutterSecureStorage();

  Future<bool> get lembrarAtivo async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kLembrar) ?? false;
  }

  Future<({String email, String senha})?> lerCredenciaisSalvas() async {
    if (!await lembrarAtivo) return null;
    final p = await SharedPreferences.getInstance();
    final email = p.getString(_kEmail);
    final senha = await _lerSenha();
    if (email == null || email.isEmpty || senha == null || senha.isEmpty) return null;
    return (email: email, senha: senha);
  }

  Future<void> salvar({required bool lembrar, required String email, required String senha}) async {
    final p = await SharedPreferences.getInstance();
    if (!lembrar) {
      await limpar();
      return;
    }
    await p.setBool(_kLembrar, true);
    await p.setString(_kEmail, email.trim());
    await _salvarSenha(senha);
  }

  Future<void> limpar() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLembrar, false);
    await p.remove(_kEmail);
    await p.remove(_kSenhaPrefs);
    try {
      await _secure.delete(key: _kSenhaSecure);
    } catch (e) {
      debugPrint('CredentialRememberService.limpar secure: $e');
    }
  }

  Future<String?> _lerSenha() async {
    if (kIsWeb) {
      final p = await SharedPreferences.getInstance();
      return p.getString(_kSenhaPrefs);
    }
    try {
      return await _secure.read(key: _kSenhaSecure);
    } catch (e) {
      debugPrint('CredentialRememberService._lerSenha: $e');
      return null;
    }
  }

  Future<void> _salvarSenha(String senha) async {
    if (kIsWeb) {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kSenhaPrefs, senha);
      return;
    }
    try {
      await _secure.write(key: _kSenhaSecure, value: senha);
    } catch (e) {
      debugPrint('CredentialRememberService._salvarSenha: $e');
    }
  }
}
