import '../utils/api_num_utils.dart';
import 'regra_financeira.dart';

class FinanceiroConfig {
  final double valorAdulto;
  final double valorMenor;
  final double desconto2oFamiliarPercent;
  final double desconto3oFamiliarPercent;
  final double descontoMesmoPagantePercent;
  final int diaVencimento;
  final List<RegraFinanceira> regrasExtras;
  final bool proRataAtivo;

  const FinanceiroConfig({
    this.valorAdulto = 110,
    this.valorMenor = 80,
    this.desconto2oFamiliarPercent = 10,
    this.desconto3oFamiliarPercent = 15,
    this.descontoMesmoPagantePercent = 5,
    this.diaVencimento = 10,
    this.regrasExtras = const [],
    this.proRataAtivo = true,
  });

  static List<RegraFinanceira> _parseRegras(dynamic raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => RegraFinanceira.fromMap(Map<String, dynamic>.from(e)))
        .where((r) => r.titulo.isNotEmpty)
        .toList();
  }

  factory FinanceiroConfig.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const FinanceiroConfig();
    return FinanceiroConfig(
      valorAdulto: apiToDouble(m['valor_adulto'], 110),
      valorMenor: apiToDouble(m['valor_menor'], 80),
      desconto2oFamiliarPercent: apiToDouble(m['desconto_2o_familiar_percent'], 10),
      desconto3oFamiliarPercent: apiToDouble(m['desconto_3o_familiar_percent'], 15),
      descontoMesmoPagantePercent: apiToDouble(m['desconto_mesmo_pagante_percent'], 5),
      diaVencimento: apiToInt(m['dia_vencimento'], 10),
      regrasExtras: _parseRegras(m['regras_extras']),
      proRataAtivo: m['pro_rata_ativo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': 1,
        'valor_adulto': valorAdulto,
        'valor_menor': valorMenor,
        'desconto_2o_familiar_percent': desconto2oFamiliarPercent,
        'desconto_3o_familiar_percent': desconto3oFamiliarPercent,
        'desconto_mesmo_pagante_percent': descontoMesmoPagantePercent,
        'dia_vencimento': diaVencimento,
        'regras_extras': regrasExtras.map((r) => r.toMap()).toList(),
        'pro_rata_ativo': proRataAtivo,
        'updated_at': DateTime.now().toIso8601String(),
      };

  List<int> get diasWhatsAppExtras => regrasExtras
      .where((r) => r.ativa && r.tipo == 'dia_whatsapp' && r.valor >= 1 && r.valor <= 28)
      .map((r) => r.valor.toInt())
      .toList();
}
