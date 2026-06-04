import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/financeiro_config.dart';
import '../../repositories/financeiro_config_repository.dart';

class FinanceiroConfigScreen extends StatefulWidget {
  const FinanceiroConfigScreen({super.key});

  @override
  State<FinanceiroConfigScreen> createState() => _FinanceiroConfigScreenState();
}

class _FinanceiroConfigScreenState extends State<FinanceiroConfigScreen> {
  final _repo = FinanceiroConfigRepository();
  final _adultoCtrl = TextEditingController();
  final _menorCtrl = TextEditingController();
  final _desc2Ctrl = TextEditingController();
  final _desc3Ctrl = TextEditingController();
  final _paganteCtrl = TextEditingController();
  final _vencCtrl = TextEditingController();
  bool _loading = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _adultoCtrl.dispose();
    _menorCtrl.dispose();
    _desc2Ctrl.dispose();
    _desc3Ctrl.dispose();
    _paganteCtrl.dispose();
    _vencCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final c = await _repo.obter();
    _adultoCtrl.text = c.valorAdulto.toStringAsFixed(2);
    _menorCtrl.text = c.valorMenor.toStringAsFixed(2);
    _desc2Ctrl.text = c.desconto2oFamiliarPercent.toStringAsFixed(0);
    _desc3Ctrl.text = c.desconto3oFamiliarPercent.toStringAsFixed(0);
    _paganteCtrl.text = c.descontoMesmoPagantePercent.toStringAsFixed(0);
    _vencCtrl.text = '${c.diaVencimento}';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _salvar() async {
    final adulto = double.tryParse(_adultoCtrl.text.replaceAll(',', '.')) ?? 110;
    final menor = double.tryParse(_menorCtrl.text.replaceAll(',', '.')) ?? 80;
    final d2 = double.tryParse(_desc2Ctrl.text.replaceAll(',', '.')) ?? 10;
    final d3 = double.tryParse(_desc3Ctrl.text.replaceAll(',', '.')) ?? 15;
    final dp = double.tryParse(_paganteCtrl.text.replaceAll(',', '.')) ?? 5;
    final venc = int.tryParse(_vencCtrl.text) ?? 10;

    setState(() => _salvando = true);
    await _repo.salvar(FinanceiroConfig(
      valorAdulto: adulto,
      valorMenor: menor,
      desconto2oFamiliarPercent: d2,
      desconto3oFamiliarPercent: d3,
      descontoMesmoPagantePercent: dp,
      diaVencimento: venc.clamp(1, 28),
    ));
    if (mounted) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas!'), backgroundColor: verdeEscuro),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações Financeiras')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: verdeEscuro))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Valores base', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _adultoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Mensalidade adulto (R\$)',
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _menorCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Mensalidade menor de 18 anos (R\$)',
                    prefixText: 'R\$ ',
                    helperText: 'Crianças e adolescentes',
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Descontos', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _desc2Ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '2º integrante da família (%)',
                    suffixText: '%',
                    helperText: 'Mesmo código em "Grupo familiar" no cadastro do aluno',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _desc3Ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '3º integrante ou mais (%)',
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _paganteCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mesmo CPF do pagante (2+ alunos) (%)',
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _vencCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dia de vencimento',
                    helperText: 'Usado nos alertas do painel BI',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: const Text('Salvar configurações'),
                ),
              ],
            ),
    );
  }
}
