import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/aluno.dart';
import '../../models/usuario.dart';
import '../../repositories/aluno_repository.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _usuario;
  Aluno? _alunoVinculado;
  bool _carregando = true;
  final _alunoRepo = AlunoRepository();

  Usuario? get usuario => _usuario;
  Aluno? get alunoVinculado => _alunoVinculado;
  bool get carregando => _carregando;
  bool get autenticado => _usuario != null;
  bool get isAdmin => _usuario?.isAdmin ?? false;
  bool get precisaCompletarCadastro =>
      !isAdmin && (_alunoVinculado == null || !_alunoVinculado!.cadastroCompleto);
  bool get aguardandoValidacao =>
      !isAdmin && _alunoVinculado != null && !_alunoVinculado!.cadastroValidado;

  Future<void> inicializar() async {
    _usuario = await AuthService.instance.recuperarSessao();
    await _carregarAlunoVinculado();
    _carregando = false;
    notifyListeners();

    AuthService.instance.authStateChanges.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.userUpdated) {
        _usuario = await AuthService.instance.recuperarSessao();
        await _carregarAlunoVinculado();
      } else if (event == AuthChangeEvent.signedOut) {
        _usuario = null;
        _alunoVinculado = null;
      }
      notifyListeners();
    });
  }

  Future<void> _carregarAlunoVinculado() async {
    if (_usuario == null || isAdmin) {
      _alunoVinculado = null;
      return;
    }
    if (_usuario!.alunoId != null) {
      _alunoVinculado = await _alunoRepo.buscarPorId(_usuario!.alunoId!);
    }
    _alunoVinculado ??= await _alunoRepo.buscarPorEmail(_usuario!.email);
    if (_alunoVinculado != null && _usuario!.alunoId == null) {
      await AuthService.instance.vincularAluno(_usuario!.id, _alunoVinculado!.id);
      _usuario = _usuario!.copyWith(alunoId: _alunoVinculado!.id);
    }
  }

  Future<void> recarregarAluno() async {
    await _carregarAlunoVinculado();
    notifyListeners();
  }

  Future<bool> loginEmail(String email, String senha) async {
    final user = await AuthService.instance.loginComEmail(email, senha);
    if (user != null) {
      _usuario = user;
      await _carregarAlunoVinculado();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> loginGoogle() async {
    await AuthService.instance.loginComGoogle();
  }

  Future<bool> criarConta(String nome, String email, String senha) async {
    final user = await AuthService.instance.criarConta(nome, email, senha);
    if (user != null) {
      _usuario = user;
      _alunoVinculado = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> vincularAlunoSalvo(Aluno aluno) async {
    if (_usuario == null) return;
    await AuthService.instance.vincularAluno(_usuario!.id, aluno.id);
    _usuario = _usuario!.copyWith(alunoId: aluno.id);
    _alunoVinculado = aluno;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _usuario = null;
    _alunoVinculado = null;
    notifyListeners();
  }

  Future<void> atualizarPerfil({String? nome, String? email}) async {
    if (_usuario == null) return;
    await AuthService.instance.atualizarPerfil(_usuario!.id, nome: nome, email: email);
    _usuario = await AuthService.instance.recuperarSessao();
    await _carregarAlunoVinculado();
    notifyListeners();
  }

  Future<void> alterarSenha(String novaSenha) async {
    await AuthService.instance.alterarSenha(novaSenha);
  }
}
