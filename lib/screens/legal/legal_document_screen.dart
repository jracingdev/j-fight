import 'package:flutter/material.dart';
import '../../core/legal/legal_texts.dart';
import '../../widgets/jfight_logo_image.dart';
import '../../core/theme.dart';

enum LegalDoc { termos, privacidade, aptidao }

class LegalDocumentScreen extends StatelessWidget {
  final LegalDoc documento;

  const LegalDocumentScreen({super.key, required this.documento});

  static Future<void> abrir(BuildContext context, LegalDoc doc) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LegalDocumentScreen(documento: doc)),
    );
  }

  String get _titulo => switch (documento) {
        LegalDoc.termos => LegalTexts.termosTitulo,
        LegalDoc.privacidade => LegalTexts.privacidadeTitulo,
        LegalDoc.aptidao => LegalTexts.aptidaoTitulo,
      };

  String get _conteudo => switch (documento) {
        LegalDoc.termos => LegalTexts.termos,
        LegalDoc.privacidade => LegalTexts.privacidade,
        LegalDoc.aptidao => LegalTexts.aptidao,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulo)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
        children: [
          Row(
            children: [
              const JFightLogoImage(height: 44, width: 44, borderRadius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_titulo, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: verdeEscuro)),
                    Text('J FIGHT · ${LegalTexts.dataAtualizacao}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _conteudo.trim(),
            style: TextStyle(fontSize: 14, height: 1.55, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}

/// Links fixos para os três documentos legais (login, sobre, loja).
class LegalDocumentLinks extends StatelessWidget {
  final bool dense;
  final Color? linkColor;

  const LegalDocumentLinks({super.key, this.dense = false, this.linkColor});

  static const _docs = [
    (LegalDoc.termos, Icons.description_outlined, 'Termos de Uso'),
    (LegalDoc.privacidade, Icons.privacy_tip_outlined, 'Política de Privacidade'),
    (LegalDoc.aptidao, Icons.health_and_safety_outlined, 'Termo de Aptidão Física'),
  ];

  @override
  Widget build(BuildContext context) {
    final color = linkColor ?? verdeEscuro;

    if (dense) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (doc, icon, label) in _docs) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(icon, color: color, size: 20),
              title: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
              trailing: Icon(Icons.chevron_right, color: color.withValues(alpha: 0.7), size: 20),
              onTap: () => LegalDocumentScreen.abrir(context, doc),
            ),
            if (doc != LegalDoc.aptidao) Divider(height: 1, color: Colors.grey.shade200),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (doc, icon, label) in _docs) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: verdeEscuro),
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => LegalDocumentScreen.abrir(context, doc),
          ),
          if (doc != LegalDoc.aptidao) const Divider(height: 1),
        ],
      ],
    );
  }
}

/// Links compactos em linha (rodapé da loja pública).
class LegalLinksRow extends StatelessWidget {
  final TextStyle? style;
  final MainAxisAlignment alignment;

  const LegalLinksRow({super.key, this.style, this.alignment = MainAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    final linkStyle = style ??
        TextStyle(fontSize: 12, color: Colors.grey.shade600, decoration: TextDecoration.underline);
    final items = <Widget>[
      _link(context, 'Termos de Uso', LegalDoc.termos, linkStyle),
      Text('·', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      _link(context, 'Privacidade', LegalDoc.privacidade, linkStyle),
      Text('·', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      _link(context, 'Aptidão Física', LegalDoc.aptidao, linkStyle),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: items,
    );
  }

  Widget _link(BuildContext context, String label, LegalDoc doc, TextStyle base) {
    return GestureDetector(
      onTap: () => LegalDocumentScreen.abrir(context, doc),
      child: Text(label, style: base.copyWith(color: verdeEscuro, fontWeight: FontWeight.w600)),
    );
  }
}
