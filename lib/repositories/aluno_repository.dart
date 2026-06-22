import '../core/api/api_client.dart';
import '../models/aluno.dart';

class AlunoRepository {
  final _api = ApiClient.instance;

  Future<List<Aluno>> listar({bool? ativo}) async {
    final data = await _api.get('/alunos', query: {
      if (ativo != null) 'ativo': ativo.toString(),
    });
    return (data as List).map((m) => Aluno.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<Aluno?> buscarPorEmail(String email) async {
    try {
      final data = await _api.get('/alunos/email/${Uri.encodeComponent(email)}');
      if (data == null) return null;
      if (data is! Map) return null;
      return Aluno.fromMap(Map<String, dynamic>.from(data));
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 204) return null;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Aluno?> buscarPorId(String id) async {
    try {
      final data = await _api.get('/alunos/$id');
      return Aluno.fromMap(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<List<Aluno>> listarPorIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final todos = await listar();
    final set = ids.toSet();
    return todos.where((a) => set.contains(a.id)).toList()..sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<List<Aluno>> listarColegasDeTurmas(String alunoId) async {
    final data = await _api.get('/alunos/colegas');
    return (data as List).map((m) => Aluno.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<Aluno> criar(Aluno aluno) async {
    final map = aluno.toMap()..remove('id');
    final data = await _api.post('/alunos', body: map);
    return Aluno.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> atualizar(Aluno aluno) async {
    final map = aluno.toMap()..remove('id');
    map['updated_at'] = DateTime.now().toIso8601String();
    await _api.patch('/alunos/${aluno.id}', body: map);
  }

  Future<void> deletar(String id) async {
    await _api.delete('/alunos/$id');
  }

  Future<void> validar(String id) async {
    await _api.post('/alunos/$id/validar');
  }

  Future<List<Aluno>> pendentesValidacao() async {
    final data = await _api.get('/alunos/pendentes');
    return (data as List).map((m) => Aluno.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> validarComTurmas(String alunoId, List<String> turmaIds) async {
    if (turmaIds.isEmpty) throw ArgumentError('Selecione pelo menos uma turma.');
    await _api.post('/alunos/$alunoId/validar-turmas', body: {'turma_ids': turmaIds});
  }
}
