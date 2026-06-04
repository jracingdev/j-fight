class FinanceiroConfig {
  final double valorAdulto;
  final double valorMenor;
  final double desconto2oFamiliarPercent;
  final double desconto3oFamiliarPercent;
  final double descontoMesmoPagantePercent;
  final int diaVencimento;

  const FinanceiroConfig({
    this.valorAdulto = 110,
    this.valorMenor = 80,
    this.desconto2oFamiliarPercent = 10,
    this.desconto3oFamiliarPercent = 15,
    this.descontoMesmoPagantePercent = 5,
    this.diaVencimento = 10,
  });

  factory FinanceiroConfig.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const FinanceiroConfig();
    return FinanceiroConfig(
      valorAdulto: (m['valor_adulto'] as num?)?.toDouble() ?? 110,
      valorMenor: (m['valor_menor'] as num?)?.toDouble() ?? 80,
      desconto2oFamiliarPercent: (m['desconto_2o_familiar_percent'] as num?)?.toDouble() ?? 10,
      desconto3oFamiliarPercent: (m['desconto_3o_familiar_percent'] as num?)?.toDouble() ?? 15,
      descontoMesmoPagantePercent: (m['desconto_mesmo_pagante_percent'] as num?)?.toDouble() ?? 5,
      diaVencimento: m['dia_vencimento'] as int? ?? 10,
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
        'updated_at': DateTime.now().toIso8601String(),
      };
}
