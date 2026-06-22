import '../core/api/api_client.dart';
import '../core/api/api_errors.dart';
import '../models/turma.dart';

class TurmaRepository {
  final _api = ApiClient.instance;

  Future<List<Turma>> listar({bool apenasAtivas = true}) async {
    final data = await _api.get('/turmas', query: {'apenas_ativas': apenasAtivas.toString()});
    return (data as List).map((m) => Turma.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<Turma?> buscarPorId(String id) async {
    try {
      final data = await _api.get('/turmas/$id');
      return Turma.fromMap(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> atualizar(Turma turma) async {
    await _api.patch('/turmas/${turma.id}', body: {
      'nome': turma.nome,
      'horario': turma.horario,
      'dias_semana': turma.diasSemana,
      'tipo': turma.tipo,
    });
  }

  Future<List<Turma>> turmasDoAluno(String alunoId) async {
    final data = await _api.get('/turmas/aluno/$alunoId');
    return (data as List).map((m) => Turma.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<List<String>> alunoIdsPorTurma(String turmaId) async {
    final data = await _api.get('/turmas/$turmaId/alunos');
    return (data as List).map((id) => id as String).toList();
  }

  Future<Map<String, List<Turma>>> turmasPorTodosAlunos() async {
    final data = await comTimeout(_api.get('/turmas/mapa/alunos'));
    final map = <String, List<Turma>>{};
    (data as Map<String, dynamic>).forEach((alunoId, turmas) {
      map[alunoId] = (turmas as List)
          .map((t) => Turma.fromMap(Map<String, dynamic>.from(t as Map)))
          .toList();
    });
    return map;
  }

  Future<Map<String, List<String>>> alunoIdsPorTodasTurmas() async {
    final data = await comTimeout(_api.get('/turmas/mapa/turma-alunos'));
    final map = <String, List<String>>{};
    (data as Map<String, dynamic>).forEach((tid, ids) {
      map[tid] = (ids as List).map((id) => id as String).toList();
    });
    return map;
  }

  Future<void> substituirTurmasAluno(String alunoId, List<String> turmaIds) async {
    await _api.put('/turmas/aluno/$alunoId', body: {'turma_ids': turmaIds});
  }

  Future<Map<String, int>> contagemAlunosPorTurma() async {
    final data = await comTimeout(_api.get('/turmas/contagem'));
    return (data as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int));
  }
}
