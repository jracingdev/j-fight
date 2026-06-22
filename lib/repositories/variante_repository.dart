import '../core/api/api_client.dart';
import '../models/produto_variante.dart';

class VarianteRepository {
  final _api = ApiClient.instance;

  Future<List<ProdutoVariante>> porProduto(String produtoId) async {
    final data = await _api.get('/produtos/$produtoId/variantes', auth: false);
    return (data as List).map((m) => ProdutoVariante.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<Map<String, List<ProdutoVariante>>> porProdutos(List<String> produtoIds) async {
    if (produtoIds.isEmpty) return {};
    final data = await _api.get('/variantes', query: {'produto_ids': produtoIds.join(',')}, auth: false);
    final map = <String, List<ProdutoVariante>>{};
    for (final row in data as List) {
      final v = ProdutoVariante.fromMap(Map<String, dynamic>.from(row as Map));
      map.putIfAbsent(v.produtoId, () => []).add(v);
    }
    return map;
  }

  Future<void> sincronizar(String produtoId, List<ProdutoVariante> variantes) async {
    await _api.put('/produtos/$produtoId/variantes', body: {
      'variantes': variantes.map((v) => v.toMap()..remove('id')).toList(),
    });
  }
}
