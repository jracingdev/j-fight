import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../api/api_client.dart';

class DriveBackup {
  static const _fileName = 'j_fight_backup.json';
  final _api = ApiClient.instance;

  Future<bool> exportar() async {
    try {
      final data = await _api.get('/backup/export');
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$_fileName');
      await file.writeAsString(json, encoding: utf8);

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json', name: _fileName)],
        subject: 'Backup J FIGHT — ${DateTime.now().toIso8601String().substring(0, 10)}',
        text: 'Backup do app J FIGHT. Salve este arquivo em local seguro.',
      );
      return result.status != ShareResultStatus.dismissed;
    } catch (_) {
      return false;
    }
  }

  Future<BackupRestoreResult> importar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecione o arquivo de backup J FIGHT',
      );
      if (result == null || result.files.isEmpty) return BackupRestoreResult.cancelado;
      final path = result.files.single.path;
      if (path == null) return BackupRestoreResult.erro;

      final content = await File(path).readAsString(encoding: utf8);
      final data = jsonDecode(content) as Map<String, dynamic>;
      if (data['app'] != 'j_fight') return BackupRestoreResult.arquivoInvalido;

      await _api.post('/backup/import', body: data);
      return BackupRestoreResult.sucesso;
    } catch (_) {
      return BackupRestoreResult.erro;
    }
  }
}

enum BackupRestoreResult { sucesso, cancelado, erro, arquivoInvalido }
