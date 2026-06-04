import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/turma.dart';
import '../utils/turma_utils.dart';

class TurmasAlunoCard extends StatelessWidget {
  final List<Turma> turmas;
  const TurmasAlunoCard({super.key, required this.turmas});

  @override
  Widget build(BuildContext context) {
    if (turmas.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Sua turma ainda não foi definida. Aguarde a validação do professor.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: turmas.map((t) {
          return ListTile(
            leading: const Icon(Icons.schedule, color: verdeEscuro),
            title: Text(t.nome, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text(
              '${formatarDiasSemana(t.diasSemana)}\n${formatarHorarioTurma(t.horario)}',
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
            isThreeLine: true,
          );
        }).toList(),
      ),
    );
  }
}
