import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

const Duration kSupabaseQueryTimeout = Duration(seconds: 12);

/// Mensagem amigável para falhas de API (tabela ausente, RLS, rede).
String mensagemErroSupabase(Object erro, {String recurso = 'dados'}) {
  if (erro is TimeoutException) {
    return 'Tempo esgotado ao carregar $recurso. Verifique sua conexão.';
  }
  if (erro is PostgrestException) {
    final code = erro.code ?? '';
    final msg = erro.message.toLowerCase();
    if (code == 'PGRST205' ||
        code == '42P01' ||
        (msg.contains('pedidos') && msg.contains('does not exist')) ||
        (msg.contains('relation') && msg.contains('does not exist'))) {
      return 'Tabela de pedidos não encontrada. Execute supabase_pedidos.sql no Supabase.';
    }
    if (code == '42501' || msg.contains('permission') || msg.contains('policy')) {
      return 'Sem permissão para acessar $recurso. Verifique login e políticas RLS.';
    }
    return erro.message;
  }
  return 'Não foi possível carregar $recurso. Tente novamente.';
}

Future<T> comTimeout<T>(Future<T> future, {Duration? timeout}) {
  return future.timeout(timeout ?? kSupabaseQueryTimeout);
}
