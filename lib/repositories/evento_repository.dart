import '../core/api/api_client.dart';
import '../models/evento.dart';

class EventoRepository {
  final _api = ApiClient.instance;

  Future<List<Evento>> listar() async {
    final data = await _api.get('/eventos');
    return (data as List).map((m) => Evento.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<Evento> criar(Evento e) async {
    final map = e.toMap()..remove('id');
    final data = await _api.post('/eventos', body: map);
    return Evento.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> atualizar(Evento e) async {
    final map = e.toMap()..remove('id');
    await _api.patch('/eventos/${e.id}', body: map);
  }

  Future<void> deletar(String id) async {
    await _api.delete('/eventos/$id');
  }
}
