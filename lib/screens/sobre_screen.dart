import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_version.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/jfight_logo_image.dart';
import '../widgets/contatos_card.dart';
import 'legal/legal_document_screen.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(children: [

          // Logo J FIGHT
          const JFightLogoImage(height: 110, width: 110, borderRadius: 20),
          const SizedBox(height: 12),
          const Text('J FIGHT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: verdeEscuro)),
          Text('Academia de Artes Marciais · desde $academiaFundacao',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 6),
          Text('Versão ${AppVersion.label}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),

          const SizedBox(height: 24),

          // Academia
          _Card(child: Column(children: [
            const JFightLogoImage(height: 96),
            const SizedBox(height: 12),
            const Text('ACADEMIA CREDENCIADA', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 4),
            const Text(academiaCredenciada,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: verdeEscuro),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: verdeEscuro.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text(academiaCredencial,
                  style: TextStyle(fontWeight: FontWeight.w800, color: verdeEscuro, fontSize: 14)),
            ),
          ])),

          const SizedBox(height: 16),

          // Professor
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.military_tech, color: verdeEscuro),
              const SizedBox(width: 8),
              const Text('Professor Responsável', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ]),
            const Divider(height: 16),
            _infoRow(Icons.person, professorNome),
            _infoRow(Icons.grade, professorGraduacao),
            _infoRow(Icons.badge_outlined, 'Registro: $professorRegistro'),
          ])),

          const SizedBox(height: 16),
          const ContatosCard(),

          const SizedBox(height: 16),

          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const Icon(Icons.gavel_outlined, color: verdeEscuro, size: 20),
              const SizedBox(width: 8),
              const Text('Documentos legais', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ]),
            const Divider(height: 20),
            const LegalDocumentLinks(),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_new, color: verdeEscuro),
              title: const Text('Política de Privacidade (web)'),
              subtitle: const Text('Link público exigido para publicação na Play Store'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final uri = Uri.parse(privacyPolicyUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_new, color: verdeEscuro),
              title: const Text('Termos de Uso (web)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final uri = Uri.parse(termsOfUseUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ])),

          const SizedBox(height: 16),

          // Desenvolvedor (discreto)
          _Card(
            color: Colors.grey.shade50,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.code, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text('Desenvolvido por', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ]),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(developerUrl);
                  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Text(developerNome,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: verdeEscuro,
                        decoration: TextDecoration.underline)),
              ),
              Text(developerUrl, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]),
          ),

          const SizedBox(height: 12),
          Text('© $academiaFundacao–${DateTime.now().year} J FIGHT · Todos os direitos reservados',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: Colors.grey.shade500),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
    ]),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _Card({required this.child, this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}
