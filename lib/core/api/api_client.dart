import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  String? _token;

  Future<void> loadToken() async {
    _token = await TokenStorage.read();
  }

  /// Garante token em memória antes de chamadas autenticadas (Android pode perder cache).
  Future<void> ensureToken() async {
    if (_token == null || _token!.isEmpty) {
      await loadToken();
    }
  }

  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      await TokenStorage.write(token);
    } else {
      await TokenStorage.clear();
    }
  }

  String? get token => _token;

  Future<Map<String, String>> _headers({bool json = true, bool auth = true}) async {
    if (auth) await ensureToken();
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (auth && _token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = apiBaseUrl.endsWith('/') ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) : apiBaseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p').replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query, bool auth = true}) async {
    final uri = _uri(path, query);
    if (kDebugMode) debugPrint('API GET $uri auth=$auth token=${_token != null}');
    final res = await http
        .get(uri, headers: await _headers(auth: auth))
        .timeout(kApiQueryTimeout);
    return _decode(res);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final uri = _uri(path);
    if (kDebugMode) debugPrint('API POST $uri auth=$auth');
    final res = await http
        .post(uri, headers: await _headers(auth: auth), body: body != null ? jsonEncode(body) : null)
        .timeout(kApiQueryTimeout);
    return _decode(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await http
        .put(_uri(path), headers: await _headers(), body: jsonEncode(body))
        .timeout(kApiQueryTimeout);
    return _decode(res);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final res = await http
        .patch(_uri(path), headers: await _headers(), body: jsonEncode(body))
        .timeout(kApiQueryTimeout);
    return _decode(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await http.delete(_uri(path), headers: await _headers()).timeout(kApiQueryTimeout);
    return _decode(res);
  }

  Future<String?> uploadFoto({
    required String pasta,
    Uint8List? bytes,
    String? filename,
    String extension = 'jpg',
  }) async {
    if (bytes == null || bytes.isEmpty) return null;
    final ext = extension == 'jpeg' ? 'jpg' : extension;
    final req = http.MultipartRequest('POST', _uri('/files/fotos'));
    await ensureToken();
    if (_token != null && _token!.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $_token';
    }
    req.fields['pasta'] = pasta;
    req.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename ?? 'foto.$ext',
    ));
    final streamed = await req.send().timeout(kApiQueryTimeout);
    final res = await http.Response.fromStream(streamed);
    final data = _decode(res);
    return data is Map ? data['url'] as String? : null;
  }

  dynamic _decode(http.Response res) {
    dynamic body;
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = res.body;
      }
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = body is Map && body['error'] != null
        ? body['error'].toString()
        : 'Erro HTTP ${res.statusCode}';
    throw ApiException(msg, statusCode: res.statusCode);
  }
}

const Duration kApiQueryTimeout = Duration(seconds: 12);

Future<T> comTimeout<T>(Future<T> future, {Duration? timeout}) {
  return future.timeout(timeout ?? kApiQueryTimeout);
}

String mensagemErroApi(Object erro, {String recurso = 'dados'}) {
  if (erro is TimeoutException) {
    return 'Tempo esgotado ao carregar $recurso. Verifique sua conexão e o servidor ($apiBaseUrl).';
  }
  if (erro is ApiException) {
    if (erro.statusCode == 401 || erro.statusCode == 403) {
      return 'Sem permissão para acessar $recurso. Faça login novamente.';
    }
    return erro.message;
  }
  return 'Não foi possível carregar $recurso. Verifique sua conexão ($apiBaseUrl).';
}
