import '../../models/aluno.dart';
import '../../models/financeiro_config.dart';
import '../../utils/bjj_utils.dart';

/// Valor base por idade (criança vs adulto) usando config ou padrão CBJJ.
double valorBaseEtario(Aluno aluno, FinanceiroConfig config) {
  if (aluno.valorMensalidadeCustom != null && aluno.valorMensalidadeCustom! > 0) {
    return aluno.valorMensalidadeCustom!;
  }
  final idade = calcularIdadeCBJJ(aluno.dataNascimento);
  if (idade != null && idade < 18) return config.valorMenor;
  return config.valorAdulto;
}

/// Calcula mensalidade com bolsa, família e mesmo pagante.
double calcularValorMensalidadeAluno(
  Aluno aluno,
  FinanceiroConfig config,
  List<Aluno> todosAtivos,
) {
  if (!aluno.cobrancaAtiva || !aluno.ativo) return 0;

  var valor = valorBaseEtario(aluno, config);

  if (aluno.bolsista && aluno.percentualBolsa > 0) {
    valor *= 1 - (aluno.percentualBolsa.clamp(0, 100) / 100);
  }

  final grupo = aluno.grupoFamiliar?.trim();
  if (grupo != null && grupo.isNotEmpty) {
    final familia = todosAtivos
        .where((a) =>
            a.cobrancaAtiva &&
            a.ativo &&
            a.cadastroValidado &&
            (a.grupoFamiliar?.trim() ?? '') == grupo)
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
    final idx = familia.indexWhere((a) => a.id == aluno.id);
    if (idx == 1) {
      valor *= 1 - (config.desconto2oFamiliarPercent / 100);
    } else if (idx >= 2) {
      valor *= 1 - (config.desconto3oFamiliarPercent / 100);
    }
  }

  final cpf = aluno.cpfPagante?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (cpf.length >= 11) {
    final qtd = todosAtivos
        .where((a) =>
            a.cobrancaAtiva &&
            a.ativo &&
            a.cadastroValidado &&
            (a.cpfPagante?.replaceAll(RegExp(r'\D'), '') ?? '') == cpf)
        .length;
    if (qtd > 1) {
      valor *= 1 - (config.descontoMesmoPagantePercent / 100);
    }
  }

  return double.parse(valor.toStringAsFixed(2));
}

/// Pro-rata: valor proporcional aos dias restantes no mês de início.
double aplicarProRata(double valorCheio, DateTime inicio) {
  final ultimoDia = DateTime(inicio.year, inicio.month + 1, 0).day;
  final diasRestantes = ultimoDia - inicio.day + 1;
  if (diasRestantes >= ultimoDia) return valorCheio;
  return double.parse((valorCheio * diasRestantes / ultimoDia).toStringAsFixed(2));
}

int mesesRestantesNoAno(int mesInicio, int anoInicio, int anoAlvo) {
  if (anoAlvo > anoInicio) return 12;
  if (anoAlvo < anoInicio) return 0;
  return 13 - mesInicio;
}
