import '../core/api/api_client.dart';
import '../models/presenca_token.dart';

class PresencaCheckinRepository {
  final _api = ApiClient.instance;

  Future<PresencaToken> criarToken({
    required String tipo,
    String? turmaId,
  }) async {
    final data = await _api.post('/presencas/tokens', body: {
      'tipo': tipo,
      if (turmaId != null) 'turma_id': turmaId,
    });
    return PresencaToken.fromRpc(Map<String, dynamic>.from(data as Map));
  }

  Future<CheckinResult> registrarCheckin(String token) async {
    final data = await _api.post('/presencas/checkin', body: {'token': token});
    return CheckinResult.fromRpc(Map<String, dynamic>.from(data as Map));
  }
}
