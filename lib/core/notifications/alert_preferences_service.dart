import 'package:shared_preferences/shared_preferences.dart';

/// Preferências de alertas sonoros e visuais (usuário pode silenciar).
class AlertPreferencesService {
  AlertPreferencesService._();
  static final instance = AlertPreferencesService._();

  static const _keySom = 'alertas_som_ativo';
  static const _keyVisual = 'alertas_visual_ativo';

  Future<bool> get alertasSomAtivos async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keySom) ?? true;
  }

  Future<bool> get alertasVisuaisAtivos async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keyVisual) ?? true;
  }

  Future<void> setAlertasSomAtivos(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keySom, value);
  }

  Future<void> setAlertasVisuaisAtivos(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyVisual, value);
  }
}
