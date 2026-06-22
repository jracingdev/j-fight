import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/api/api_errors.dart';
import '../models/pedido.dart';

class PedidoRepository {
  final _api = ApiClient.instance;

  Future<List<Pedido>> listar({String? status}) async {
    try {
      final data = await comTimeout(_api.get('/pedidos', query: {
        if (status != null) 'status': status,
      }));
      return (data as List).map((m) => Pedido.fromMap(Map<String, dynamic>.from(m))).toList();
    } catch (e, st) {
      debugPrint('PedidoRepository.listar: $e\n$st');
      rethrow;
    }
  }

  Future<List<Pedido>> meusPedidos(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return [];
    try {
      final data = await comTimeout(_api.get('/pedidos'));
      return (data as List).map((m) => Pedido.fromMap(Map<String, dynamic>.from(m))).toList();
    } catch (e, st) {
      debugPrint('PedidoRepository.meusPedidos: $e\n$st');
      rethrow;
    }
  }

  Future<Pedido> criar(Pedido p) async {
    final map = p.toMap()..remove('id');
    if (map['aluno_email'] != null) {
      map['aluno_email'] = (map['aluno_email'] as String).trim().toLowerCase();
    }
    final data = await comTimeout(_api.post('/pedidos', body: map, auth: p.alunoId != null));
    return Pedido.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    await comTimeout(_api.patch('/pedidos/$id', body: {
      'status': novoStatus,
      if (novoStatus == 'enviado') 'data_envio': DateTime.now().toIso8601String().split('T')[0],
    }));
  }

  Future<void> atualizarRastreamento(String id, {
    required String? codigo,
    required String? transportadora,
    required String? link,
    required String? dataEntrega,
  }) async {
    await comTimeout(_api.patch('/pedidos/$id', body: {
      'codigo_rastreamento': codigo,
      'transportadora': transportadora,
      'link_rastreamento': link,
      'data_entrega_estimada': dataEntrega,
    }));
  }

  Future<void> marcarPago(String id) async {
    await comTimeout(_api.patch('/pedidos/$id', body: {
      'pago': true,
      'data_pagamento': DateTime.now().toIso8601String().split('T')[0],
    }));
  }

  Future<void> atualizarLinkPagamento(String id, String link) async {
    await comTimeout(_api.patch('/pedidos/$id', body: {
      'link_pagamento': link,
      'forma_pagamento': 'mercadopago',
    }));
  }

  Future<void> atualizarObsAdmin(String id, String obs) async {
    await comTimeout(_api.patch('/pedidos/$id', body: {'observacoes_admin': obs}));
  }

  Future<void> deletar(String id) async {
    await comTimeout(_api.delete('/pedidos/$id'));
  }
}
