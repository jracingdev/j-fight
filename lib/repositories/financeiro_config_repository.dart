import '../core/api/api_client.dart';
import '../core/api/api_errors.dart';
import '../models/financeiro_config.dart';

class FinanceiroConfigRepository {
  final _api = ApiClient.instance;

  Future<FinanceiroConfig> obter() async {
    try {
      final data = await comTimeout(_api.get('/financeiro/config'));
      return FinanceiroConfig.fromMap(data as Map<String, dynamic>?);
    } catch (_) {
      return const FinanceiroConfig();
    }
  }

  Future<void> salvar(FinanceiroConfig config) async {
    await comTimeout(_api.put('/financeiro/config', body: config.toMap()));
  }
}
