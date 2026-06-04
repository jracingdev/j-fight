import '../core/supabase_errors.dart';
import '../core/supabase_service.dart';
import '../models/financeiro_config.dart';

class FinanceiroConfigRepository {
  Future<FinanceiroConfig> obter() async {
    try {
      final data = await comTimeout(
        supabase.from('financeiro_config').select().eq('id', 1).maybeSingle(),
      );
      return FinanceiroConfig.fromMap(data);
    } catch (_) {
      return const FinanceiroConfig();
    }
  }

  Future<void> salvar(FinanceiroConfig config) async {
    await comTimeout(
      supabase.from('financeiro_config').upsert(config.toMap()),
    );
  }
}
