import 'package:flutter/foundation.dart';
import '../../models/usuario.dart';
import '../api/api_client.dart';
import 'auth_result.dart';
import 'google_native_sign_in.dart';
import '../app_platform.dart';

/// Apenas estes e-mails podem ter role admin (case-insensitive).
const Set<String> kAdminEmails = {
  'admin@jfight.app',
};

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _api = ApiClient.instance;

  static String roleForEmail(String? email) {
    final normalized = email?.trim().toLowerCase();
    if (normalized != null && kAdminEmails.contains(normalized)) {
      return 'admin';
    }
    return 'aluno';
  }

  Future<AuthResult> loginComEmail(String email, String senha) async {
    try {
      final data = await _api.post('/auth/login', body: {
        'email': email.trim(),
        'password': senha,
      }, auth: false);
      return _processarRespostaAuth(data);
    } on ApiException catch (e) {
      return AuthResult(status: AuthStatus.error, message: e.message);
    } catch (e) {
      debugPrint('loginComEmail: $e');
      return const AuthResult(status: AuthStatus.error, message: 'Erro ao entrar. Verifique sua conexão.');
    }
  }

  Future<AuthResult> loginComGoogle() async {
    if (isNativeApp && GoogleNativeSignIn.disponivel) {
      try {
        final idToken = await GoogleNativeSignIn.signIn();
        if (idToken == null) {
          return const AuthResult(
            status: AuthStatus.error,
            message: 'Login Google cancelado.',
          );
        }
        final data = await _api.post('/auth/google', body: {'id_token': idToken}, auth: false);
        return _processarRespostaAuth(data);
      } catch (e, st) {
        debugPrint('loginComGoogle nativo: $e\n$st');
        return AuthResult(
          status: AuthStatus.error,
          message: e is ApiException ? e.message : 'Não foi possível concluir o login Google.',
        );
      }
    }

    return const AuthResult(
      status: AuthStatus.error,
      message: 'Login Google disponível apenas no app Android/iOS. Use e-mail e senha na web.',
    );
  }

  Future<AuthResult> criarConta(String nome, String email, String senha) async {
    try {
      final data = await _api.post('/auth/register', body: {
        'nome': nome.trim(),
        'email': email.trim(),
        'password': senha,
      }, auth: false);
      return _processarRespostaAuth(data);
    } on ApiException catch (e) {
      return AuthResult(status: AuthStatus.error, message: e.message);
    } catch (e) {
      debugPrint('criarConta: $e');
      return const AuthResult(status: AuthStatus.error, message: 'Erro ao criar conta. Tente novamente.');
    }
  }

  Future<Usuario?> recuperarSessao() async {
    await _api.loadToken();
    if (_api.token == null) return null;
    try {
      final data = await _api.get('/auth/me');
      final map = data['usuario'] as Map<String, dynamic>?;
      if (map == null) return null;
      return Usuario.fromMap(map);
    } catch (e) {
      debugPrint('recuperarSessao: $e');
      await _api.setToken(null);
      return null;
    }
  }

  Future<AuthResult> _processarRespostaAuth(dynamic data) async {
    final token = data['access_token'] as String?;
    final usuarioMap = data['usuario'] as Map<String, dynamic>?;
    if (token == null || usuarioMap == null) {
      return const AuthResult(
        status: AuthStatus.error,
        message: 'Resposta inválida do servidor.',
      );
    }
    await _api.setToken(token);
    return AuthResult(status: AuthStatus.success, usuario: Usuario.fromMap(usuarioMap));
  }

  Future<void> atualizarPerfil(String uid, {String? nome, String? email}) async {
    await _api.patch('/auth/me', body: {
      if (nome != null) 'nome': nome,
      if (email != null) 'email': email,
    });
  }

  Future<void> alterarSenha(String novaSenha) async {
    await _api.patch('/auth/me/password', body: {'password': novaSenha});
  }

  Future<AuthResult> recuperarSenha(String email) async {
    final e = email.trim();
    if (e.isEmpty || !e.contains('@')) {
      return const AuthResult(status: AuthStatus.error, message: 'Informe um e-mail válido.');
    }
    try {
      final data = await _api.post('/auth/forgot-password', body: {'email': e}, auth: false);
      return AuthResult(
        status: AuthStatus.success,
        message: data['message'] as String? ?? 'Instruções enviadas se o e-mail existir.',
      );
    } on ApiException catch (ex) {
      return AuthResult(status: AuthStatus.error, message: ex.message);
    } catch (e) {
      debugPrint('recuperarSenha: $e');
      return const AuthResult(
        status: AuthStatus.error,
        message: 'Não foi possível enviar o e-mail. Tente novamente.',
      );
    }
  }

  Future<void> vincularAluno(String userId, String alunoId) async {
    await _api.patch('/auth/users/$userId/aluno', body: {'aluno_id': alunoId});
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _api.setToken(null);
  }
}
