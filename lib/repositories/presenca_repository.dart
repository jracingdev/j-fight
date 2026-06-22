import '../core/api/api_client.dart';
import '../core/api/api_errors.dart';
import '../models/presenca.dart';

class PresencaRepository {
  final _api = ApiClient.instance;

  Future<List<Presenca>> porTurmaEData(String turmaId, String dataIso) async {
    final data = await comTimeout(_api.get('/presencas', query: {
      'turma_id': turmaId,
      'data_aula': dataIso,
    }));
    return (data as List).map((m) => Presenca.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<List<Presenca>> porAluno(String alunoId, {int limite = 30}) async {
    final data = await comTimeout(_api.get('/presencas', query: {'limite': limite.toString()}));
    return (data as List).map((m) => Presenca.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<int> contarPresencasMes(String alunoId, int mes, int ano) async {
    final data = await comTimeout(_api.get('/presencas/contagem-mes', query: {
      'mes': mes.toString(),
      'ano': ano.toString(),
    }));
    return (data as Map)['total'] as int? ?? 0;
  }

  Future<void> salvarChamada({
    required String turmaId,
    required String dataIso,
    required Map<String, ({String nome, bool presente})> porAluno,
  }) async {
    final map = <String, dynamic>{};
    porAluno.forEach((id, info) {
      map[id] = {'nome': info.nome, 'presente': info.presente};
    });
    await comTimeout(_api.put('/presencas/chamada', body: {
      'turma_id': turmaId,
      'data_aula': dataIso,
      'por_aluno': map,
    }));
  }

  Future<void> remover(String id) async {
    await comTimeout(_api.delete('/presencas/$id'));
  }
}
