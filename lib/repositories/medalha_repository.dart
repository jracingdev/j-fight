import '../core/api/api_client.dart';
import '../models/medalha.dart';

class MedalhaRepository {
  final _api = ApiClient.instance;

  Future<List<Medalha>> listar({bool apenasAtivas = true}) async {
    final data = await _api.get('/medalhas', query: {
      if (apenasAtivas) 'ativo': 'true',
    });
    return (data as List).map((m) => Medalha.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> criar(Medalha medalha) async {
    final map = medalha.toMap()..remove('id');
    await _api.post('/medalhas', body: map);
  }

  Future<void> atualizar(Medalha medalha) async {
    final map = medalha.toMap()..remove('id');
    await _api.patch('/medalhas/${medalha.id}', body: map);
  }

  Future<void> remover(String id) async {
    await _api.delete('/medalhas/$id');
  }
}
