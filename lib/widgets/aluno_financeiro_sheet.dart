import 'package:flutter/material.dart';
import '../core/financeiro/mensalidade_gerador_service.dart';
import '../core/theme.dart';
import '../models/aluno.dart';
import '../repositories/aluno_repository.dart';
import '../repositories/financeiro_config_repository.dart';

/// Edição financeira do aluno e interrupção de cobrança.
class AlunoFinanceiroSheet extends StatefulWidget {
  final Aluno aluno;
  const AlunoFinanceiroSheet({super.key, required this.aluno});

  @override
  State<AlunoFinanceiroSheet> createState() => _AlunoFinanceiroSheetState();
}

class _AlunoFinanceiroSheetState extends State<AlunoFinanceiroSheet> {
  final _alunoRepo = AlunoRepository();
  final _configRepo = FinanceiroConfigRepository();
  final _gerador = MensalidadeGeradorService();

  late bool _bolsista;
  late TextEditingController _pctBolsa;
  late TextEditingController _grupo;
  late TextEditingController _cpfPagante;
  late TextEditingController _valorCustom;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final a = widget.aluno;
    _bolsista = a.bolsista;
    _pctBolsa = TextEditingController(text: a.percentualBolsa.toStringAsFixed(0));
    _grupo = TextEditingController(text: a.grupoFamiliar ?? '');
    _cpfPagante = TextEditingController(text: a.cpfPagante ?? '');
    _valorCustom = TextEditingController(
      text: a.valorMensalidadeCustom != null ? a.valorMensalidadeCustom!.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _pctBolsa.dispose();
    _grupo.dispose();
    _cpfPagante.dispose();
    _valorCustom.dispose();
    super.dispose();
  }

  Future<void> _salvarFinanceiro() async {
    setState(() => _salvando = true);
    final custom = double.tryParse(_valorCustom.text.replaceAll(',', '.'));
    final atualizado = widget.aluno.copyWith(
      bolsista: _bolsista,
      percentualBolsa: double.tryParse(_pctBolsa.text) ?? 0,
      grupoFamiliar: _grupo.text.trim().isEmpty ? null : _grupo.text.trim(),
      cpfPagante: _cpfPagante.text.trim().isEmpty ? null : _cpfPagante.text.trim(),
      valorMensalidadeCustom: custom,
    );
    await _alunoRepo.atualizar(atualizado);
    if (mounted) {
      setState(() => _salvando = false);
      Navigator.pop(context, atualizado);
    }
  }

  Future<void> _regenerarMensalidades() async {
    final cfg = await _configRepo.obter();
    final a = await _alunoRepo.buscarPorId(widget.aluno.id) ?? widget.aluno;
    final n = await _gerador.gerarAnoVigente(a, cfg);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$n mensalidade(s) gerada(s) para o ano vigente.'), backgroundColor: verdeEscuro),
      );
    }
  }

  Future<void> _interromper() async {
    final justCtrl = TextEditingController();
    var proRata = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Interromper cobrança'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O aluno será inativado e as mensalidades futuras pendentes serão canceladas.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: justCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Justificativa *',
                  hintText: 'Ex.: mudança de cidade, lesão, etc.',
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: proRata,
                onChanged: (v) => setD(() => proRata = v ?? false),
                title: const Text('Cobrar pró-rata no mês atual', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, justCtrl.text.trim().isNotEmpty),
              child: const Text('Confirmar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _salvando = true);
    final cfg = await _configRepo.obter();
    await _gerador.interromperCobranca(
      aluno: widget.aluno,
      justificativa: justCtrl.text.trim(),
      aplicarProRataMesAtual: proRata,
      config: cfg,
    );
    justCtrl.dispose();
    if (mounted) {
      Navigator.pop(context, 'interrompido');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cobrança interrompida.'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Financeiro — ${widget.aluno.nome}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Bolsista'),
              value: _bolsista,
              onChanged: (v) => setState(() => _bolsista = v),
            ),
            if (_bolsista)
              TextField(
                controller: _pctBolsa,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Percentual da bolsa (%)', suffixText: '%'),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _grupo,
              decoration: const InputDecoration(
                labelText: 'Grupo familiar (código)',
                helperText: 'Mesmo código para irmãos da mesma família',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cpfPagante,
              decoration: const InputDecoration(
                labelText: 'CPF do responsável/pagante',
                helperText: 'Desconto quando o mesmo pagante paga 2+ alunos',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valorCustom,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor fixo (opcional)',
                prefixText: 'R\$ ',
                helperText: 'Substitui tabela adulto/menor se preenchido',
              ),
            ),
            if (widget.aluno.dataInicioCobranca != null) ...[
              const SizedBox(height: 8),
              Text('Início cobrança: ${widget.aluno.dataInicioCobranca}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _salvando ? null : _regenerarMensalidades,
              icon: const Icon(Icons.autorenew),
              label: const Text('Gerar mensalidades do ano vigente'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _salvando ? null : _salvarFinanceiro,
              icon: const Icon(Icons.save),
              label: const Text('Salvar dados financeiros'),
            ),
            if (widget.aluno.cobrancaAtiva && widget.aluno.cadastroValidado) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _salvando ? null : _interromper,
                icon: const Icon(Icons.pause_circle_outline, color: Colors.red),
                label: const Text('Interromper cobrança e inativar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
