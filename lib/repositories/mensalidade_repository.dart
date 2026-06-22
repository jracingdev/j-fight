import '../core/api/api_client.dart';
import '../core/api/api_errors.dart';
import '../core/mp_service.dart';
import '../models/mensalidade.dart';

class MensalidadeRepository {
  final _api = ApiClient.instance;

  Future<List<Mensalidade>> listar({int? mes, int? ano, bool incluirCanceladas = false}) async {
    final data = await comTimeout(_api.get('/mensalidades', query: {
      if (mes != null) 'mes': mes.toString(),
      if (ano != null) 'ano': ano.toString(),
    }));
    var lista = (data as List).map((m) => Mensalidade.fromMap(Map<String, dynamic>.from(m))).toList();
    if (!incluirCanceladas) {
      lista = lista.where((m) => !m.cancelada).toList();
    }
    return lista;
  }

  Future<List<Mensalidade>> porAluno(String alunoId) async {
    final data = await comTimeout(_api.get('/mensalidades/aluno/$alunoId'));
    return (data as List).map((m) => Mensalidade.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<bool> existeMesAno(String alunoId, int mes, int ano) async {
    final data = await comTimeout(_api.get('/mensalidades/existe', query: {
      'aluno_id': alunoId,
      'mes': mes.toString(),
      'ano': ano.toString(),
    }));
    return (data as Map)['existe'] == true;
  }

  Future<Mensalidade> criar(Mensalidade m) async {
    final map = m.toMap()..remove('id');
    final data = await comTimeout(_api.post('/mensalidades', body: map));
    return Mensalidade.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> atualizar(Mensalidade m) async {
    final map = m.toMap()..remove('id');
    await comTimeout(_api.patch('/mensalidades/${m.id}', body: map));
  }

  Future<void> marcarPago(String id) async {
    await comTimeout(_api.post('/mensalidades/$id/pagar'));
  }

  Future<void> limparPreferenciaMp(String id) async {
    await comTimeout(_api.patch('/mensalidades/$id/mp-preferencia', body: {'mp_preferencia_id': null}));
  }

  Future<void> salvarPreferenciaId(String id, String preferenciaId) async {
    await comTimeout(_api.patch('/mensalidades/$id/mp-preferencia', body: {'mp_preferencia_id': preferenciaId}));
  }

  Future<int> sincronizarStatusMP() async {
    final token = await MercadoPagoService.instance.getAccessToken();
    if (token == null || token.isEmpty) return 0;

    final data = await comTimeout(_api.get('/mensalidades/sync-mp/pendentes'));
    final pendentes = (data as List).map((m) => Mensalidade.fromMap(Map<String, dynamic>.from(m))).toList();
    if (pendentes.isEmpty) return 0;

    int marcadas = 0;
    await Future.wait(pendentes.map((m) async {
      if (m.status == 'pago') return;
      final status = await MercadoPagoService.instance.consultarStatus(m.mpPreferenciaId!);
      if (status == 'approved') {
        await marcarPago(m.id);
        marcadas++;
      }
    }));
    return marcadas;
  }

  Future<void> deletar(String id) async {
    await comTimeout(_api.delete('/mensalidades/$id'));
  }

  Future<void> cancelarFuturas({
    required String alunoId,
    required int aPartirMes,
    required int aPartirAno,
    required String justificativa,
  }) async {
    await comTimeout(_api.post('/mensalidades/cancelar-futuras', body: {
      'aluno_id': alunoId,
      'a_partir_mes': aPartirMes,
      'a_partir_ano': aPartirAno,
      'justificativa': justificativa,
    }));
  }
}
