import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_errors.dart';
import '../models/produto.dart';

class ProdutoRepository {
  final _api = ApiClient.instance;

  Future<List<Produto>> listar({bool? ativo}) async {
    try {
      final data = await comTimeout(_api.get('/produtos', query: {
        if (ativo != null) 'ativo': ativo.toString(),
      }, auth: ativo == null));
      return (data as List).map((m) => Produto.fromMap(Map<String, dynamic>.from(m))).toList();
    } catch (e, st) {
      debugPrint('ProdutoRepository.listar: $e\n$st');
      rethrow;
    }
  }

  Future<Produto> criar(Produto p) async {
    final map = p.toMap()..remove('id');
    final data = await _api.post('/produtos', body: map);
    return Produto.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> atualizar(Produto p) async {
    final map = p.toMap()..remove('id');
    await _api.patch('/produtos/${p.id}', body: map);
  }

  Future<void> deletar(String id) async {
    await _api.delete('/produtos/$id');
  }
}
