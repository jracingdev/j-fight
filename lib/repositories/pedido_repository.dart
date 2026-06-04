import 'package:flutter/foundation.dart';

import '../core/supabase_errors.dart';
import '../core/supabase_service.dart';
import '../models/pedido.dart';

/// Colunas usadas nas listagens (menos dados = mais rápido).
const _colsLista = '''
id, aluno_id, aluno_nome, aluno_email, aluno_telefone,
produto_id, produto_nome, variante_cor, variante_tamanho,
quantidade, valor_unitario, valor_total, status, forma_pagamento,
link_pagamento, pago, data_pagamento, codigo_rastreamento,
transportadora, link_rastreamento, data_envio, data_entrega_estimada,
observacoes, observacoes_admin, created_at
''';

class PedidoRepository {
  Future<List<Pedido>> listar({String? status}) async {
    try {
      var q = supabase.from('pedidos').select(_colsLista);
      if (status != null) q = q.eq('status', status);
      final data = await comTimeout(q.order('created_at', ascending: false));
      return (data as List).map((m) => Pedido.fromMap(m)).toList();
    } catch (e, st) {
      debugPrint('PedidoRepository.listar: $e\n$st');
      rethrow;
    }
  }

  Future<List<Pedido>> meusPedidos(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return [];
    try {
      final data = await comTimeout(
        supabase
            .from('pedidos')
            .select(_colsLista)
            .eq('aluno_email', normalized)
            .order('created_at', ascending: false),
      );
      return (data as List).map((m) => Pedido.fromMap(m)).toList();
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
    final data = await comTimeout(
      supabase.from('pedidos').insert(map).select().single(),
    );
    return Pedido.fromMap(data);
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    await comTimeout(
      supabase.from('pedidos').update({
        'status': novoStatus,
        'updated_at': DateTime.now().toIso8601String(),
        if (novoStatus == 'enviado') 'data_envio': DateTime.now().toIso8601String().split('T')[0],
      }).eq('id', id),
    );
  }

  Future<void> atualizarRastreamento(String id, {
    required String? codigo,
    required String? transportadora,
    required String? link,
    required String? dataEntrega,
  }) async {
    await comTimeout(
      supabase.from('pedidos').update({
        'codigo_rastreamento': codigo,
        'transportadora': transportadora,
        'link_rastreamento': link,
        'data_entrega_estimada': dataEntrega,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id),
    );
  }

  Future<void> marcarPago(String id) async {
    await comTimeout(
      supabase.from('pedidos').update({
        'pago': true,
        'data_pagamento': DateTime.now().toIso8601String().split('T')[0],
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id),
    );
  }

  Future<void> atualizarLinkPagamento(String id, String link) async {
    await comTimeout(
      supabase.from('pedidos').update({
        'link_pagamento': link,
        'forma_pagamento': 'mercadopago',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id),
    );
  }

  Future<void> atualizarObsAdmin(String id, String obs) async {
    await comTimeout(
      supabase.from('pedidos').update({
        'observacoes_admin': obs,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id),
    );
  }

  Future<void> deletar(String id) async {
    await comTimeout(supabase.from('pedidos').delete().eq('id', id));
  }
}
