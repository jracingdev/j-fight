import '../../models/aluno.dart';
import '../../models/financeiro_config.dart';
import '../../models/mensalidade.dart';
import '../../models/turma.dart';
import 'calculo_mensalidade.dart';

class ProjecaoTurma {
  final Turma turma;
  final int qtdAlunos;
  final double receitaMensal;
  final double receitaAnoRestante;

  const ProjecaoTurma({
    required this.turma,
    required this.qtdAlunos,
    required this.receitaMensal,
    required this.receitaAnoRestante,
  });
}

class ResumoProjecao {
  final double receitaMensalTotal;
  final double projecaoPositivaAno;
  final double riscoInadimplencia;
  final double gapMesAtual;
  final List<ProjecaoTurma> porTurma;

  const ResumoProjecao({
    required this.receitaMensalTotal,
    required this.projecaoPositivaAno,
    required this.riscoInadimplencia,
    required this.gapMesAtual,
    required this.porTurma,
  });
}

ResumoProjecao calcularProjecao({
  required List<Aluno> alunosAtivos,
  required FinanceiroConfig config,
  required List<Mensalidade> mensalidadesAno,
  required Map<String, List<String>> alunoIdsPorTurma,
  required List<Turma> turmas,
  required int mesRef,
  required int anoRef,
}) {
  final validados = alunosAtivos
      .where((a) => a.cadastroValidado && a.cobrancaAtiva && a.ativo)
      .toList();

  double receitaMensal = 0;
  var projAno = 0.0;
  for (final a in validados) {
    final v = calcularValorMensalidadeAluno(a, config, validados);
    receitaMensal += v;
    final inicio = a.dataInicioCobranca != null
        ? DateTime.tryParse(a.dataInicioCobranca!) ?? DateTime(anoRef, 1)
        : DateTime(anoRef, 1);
    final from = anoRef == inicio.year ? (mesRef < inicio.month ? inicio.month : mesRef) : mesRef;
    projAno += v * mesesRestantesNoAno(from, inicio.year, anoRef);
  }

  final doMes = mensalidadesAno.where((m) => m.mes == mesRef && m.ano == anoRef && !m.cancelada);
  final esperadoMes = receitaMensal;
  final arrecadado = doMes.where((m) => m.status == 'pago').fold(0.0, (s, m) => s + m.valor);
  final gap = esperadoMes - arrecadado;

  final pendentesAtrasados = mensalidadesAno
      .where((m) => !m.cancelada && m.status != 'pago')
      .fold(0.0, (s, m) => s + m.valor);

  final porTurma = <ProjecaoTurma>[];
  for (final t in turmas) {
    final ids = alunoIdsPorTurma[t.id] ?? [];
    final alunosTurma = validados.where((a) => ids.contains(a.id)).toList();
    var recMes = 0.0;
    var recAno = 0.0;
    for (final a in alunosTurma) {
      final v = calcularValorMensalidadeAluno(a, config, validados);
      recMes += v;
      final inicio = a.dataInicioCobranca != null
          ? DateTime.tryParse(a.dataInicioCobranca!) ?? DateTime(anoRef, 1)
          : DateTime(anoRef, 1);
      final from = anoRef == inicio.year ? (mesRef < inicio.month ? inicio.month : mesRef) : mesRef;
      recAno += v * mesesRestantesNoAno(from, inicio.year, anoRef);
    }
    porTurma.add(ProjecaoTurma(
      turma: t,
      qtdAlunos: alunosTurma.length,
      receitaMensal: recMes,
      receitaAnoRestante: recAno,
    ));
  }
  porTurma.sort((a, b) => b.receitaMensal.compareTo(a.receitaMensal));

  return ResumoProjecao(
    receitaMensalTotal: receitaMensal,
    projecaoPositivaAno: projAno,
    riscoInadimplencia: pendentesAtrasados,
    gapMesAtual: gap,
    porTurma: porTurma,
  );
}
