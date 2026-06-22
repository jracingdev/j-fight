import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../widgets/jfight_logo_image.dart';
import 'alert_preferences_service.dart';

/// Alertas visuais e sonoros in-app (logo + som + banner flutuante).
class AppAlertService {
  static OverlayEntry? _overlayAtivo;

  static Future<void> alertar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    Color? cor,
    Duration duracao = const Duration(seconds: 7),
  }) async {
    if (!context.mounted) return;

    final prefs = AlertPreferencesService.instance;
    final somAtivo = await prefs.alertasSomAtivos;
    final visualAtivo = await prefs.alertasVisuaisAtivos;
    if (!somAtivo && !visualAtivo) return;

    if (somAtivo && !kIsWeb) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
      try {
        await FlutterRingtonePlayer().playNotification();
      } catch (_) {
        try {
          await SystemSound.play(SystemSoundType.alert);
        } catch (_) {
          try {
            await SystemSound.play(SystemSoundType.click);
          } catch (_) {}
        }
      }
    }

    if (!visualAtivo || !context.mounted) return;

    _overlayAtivo?.remove();
    _overlayAtivo = null;

    final bg = cor ?? Colors.orange.shade800;
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final top = MediaQuery.of(ctx).padding.top;
        return Positioned(
          top: top + 8,
          left: 12,
          right: 12,
          child: Material(
            elevation: 10,
            shadowColor: Colors.black45,
            borderRadius: BorderRadius.circular(16),
            color: bg,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const JFightLogoImage(height: 48, width: 48, borderRadius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mensagem,
                          style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () {
                      entry.remove();
                      if (_overlayAtivo == entry) _overlayAtivo = null;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _overlayAtivo = entry;

    Future.delayed(duracao, () {
      if (entry.mounted) {
        entry.remove();
        if (_overlayAtivo == entry) _overlayAtivo = null;
      }
    });
  }
}
