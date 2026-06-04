import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/turma.dart';
import '../../repositories/turma_repository.dart';
import '../../utils/turma_utils.dart';

class TurmasScreen extends StatefulWidget {
  const TurmasScreen({super.key});

  @override
  State<TurmasScreen> createState() => _TurmasScreenState();
}

class _TurmasScreenState extends State<TurmasScreen> {
  final _repo = TurmaRepository();
  List<Turma> _turmas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _turmas = await _repo.listar(apenasAtivas: false);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _editarDias(Turma turma) async {
    final selecionados = Set<String>.from(turma.diasSemana);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(turma.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('Horário: ${formatarHorarioTurma(turma.horario)}', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  const Text('Dias da semana', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...diasSemanaOpcoes.map((d) {
                    final id = d['id']!;
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selecionados.contains(id),
                      title: Text(d['label']!),
                      onChanged: (v) {
                        setModalState(() {
                          if (v == true) {
                            selecionados.add(id);
                          } else {
                            selecionados.remove(id);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Salvar dias'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (ok == true) {
      final ordenados = diasSemanaOpcoes
          .map((d) => d['id']!)
          .where(selecionados.contains)
          .toList();
      await _repo.atualizar(turma.copyWith(diasSemana: ordenados));
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dias da turma atualizados!'), backgroundColor: verdeEscuro),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turmas'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: verdeEscuro))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _turmas.length,
              itemBuilder: (_, i) {
                final t = _turmas[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: verdeEscuro,
                      child: Text(
                        t.horario.substring(0, 2),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(t.nome, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${formatarHorarioTurma(t.horario)} · ${t.tipo}'),
                        const SizedBox(height: 4),
                        Text(
                          formatarDiasSemana(t.diasSemana),
                          style: TextStyle(
                            fontSize: 12,
                            color: t.diasSemana.isEmpty ? Colors.orange.shade800 : Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_month, color: verdeEscuro),
                      onPressed: () => _editarDias(t),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
