import '../core/supabase_service.dart';
import '../models/pedido.dart';

class PedidoRepository {
  Future<List<Pedido>> listar({String? status}) async {
    var q = supabase.from('pedidos').select();
    if (status != null) q = q.eq('status', status);
    final data = await q.order('created_at', ascending: false);
    return (data as List).map((m) => Pedido.fromMap(m)).toList();
  }

  Future<List<Pedido>> meusPedidos(String email) async {
    final data = await supabase.from('pedidos').select()
        .eq('aluno_email', email).order('created_at', ascending: false);
    return (data as List).map((m) => Pedido.fromMap(m)).toList();
  }

  Future<Pedido> criar(Pedido p) async {
    final map = p.toMap()..remove('id');
    final data = await supabase.from('pedidos').insert(map).select().single();
    return Pedido.fromMap(data);
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    await supabase.from('pedidos').update({
      'status': novoStatus,
      'updated_at': DateTime.now().toIso8601String(),
      if (novoStatus == 'enviado') 'data_envio': DateTime.now().toIso8601String().split('T')[0],
    }).eq('id', id);
  }

  Future<void> atualizarRastreamento(String id, {
    required String? codigo,
    required String? transportadora,
    required String? link,
    required String? dataEntrega,
  }) async {
    await supabase.from('pedidos').update({
      'codigo_rastreamento': codigo,
      'transportadora': transportadora,
      'link_rastreamento': link,
      'data_entrega_estimada': dataEntrega,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> marcarPago(String id) async {
    await supabase.from('pedidos').update({
      'pago': true,
      'data_pagamento': DateTime.now().toIso8601String().split('T')[0],
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> atualizarLinkPagamento(String id, String link) async {
    await supabase.from('pedidos').update({
      'link_pagamento': link,
      'forma_pagamento': 'mercadopago',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> atualizarObsAdmin(String id, String obs) async {
    await supabase.from('pedidos').update({
      'observacoes_admin': obs,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deletar(String id) async {
    await supabase.from('pedidos').delete().eq('id', id);
  }
}
