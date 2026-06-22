import '../core/api/api_client.dart';
import '../models/presenca_config.dart';

class PresencaConfigRepository {
  final _api = ApiClient.instance;

  Future<PresencaConfig> obter() async {
    final data = await _api.get('/presencas/config');
    return PresencaConfig.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> salvar(PresencaConfig config) async {
    await _api.put('/presencas/config', body: config.toMap());
  }
}
