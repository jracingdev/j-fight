import '../core/api/api_client.dart';
import '../models/aviso.dart';

class AvisoRepository {
  final _api = ApiClient.instance;

  Future<List<Aviso>> listar({bool? apenasAtivos}) async {
    final data = await _api.get('/avisos', query: {
      if (apenasAtivos == true) 'ativo': 'true',
    });
    return (data as List).map((m) => Aviso.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<Aviso> criar(Aviso a) async {
    final map = a.toMap()..remove('id');
    final data = await _api.post('/avisos', body: map);
    return Aviso.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> atualizar(Aviso a) async {
    final map = a.toMap()..remove('id');
    await _api.patch('/avisos/${a.id}', body: map);
  }

  Future<void> deletar(String id) async {
    await _api.delete('/avisos/$id');
  }
}
