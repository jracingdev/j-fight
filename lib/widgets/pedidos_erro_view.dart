import 'package:flutter/material.dart';
class PedidosErroView extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;
  const PedidosErroView({super.key, required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.orange.shade700),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class PedidosListaVazia extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  const PedidosListaVazia({super.key, required this.titulo, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(titulo, style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w600)),
          if (subtitulo != null) ...[
            const SizedBox(height: 8),
            Text(subtitulo!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
