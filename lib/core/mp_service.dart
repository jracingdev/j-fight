import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api_client.dart';
import 'api/api_config.dart';

class MercadoPagoService {
  static final MercadoPagoService instance = MercadoPagoService._();
  MercadoPagoService._();

  static final _baseUrl = 'https://api.mercadopago.com';
  static const _prefKey = 'mp_access_token';
  static String get _webhookUrl => '$apiPublicUrl/api/v1/webhooks/mercadopago';

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, token);
    try {
      await ApiClient.instance.patch('/financeiro/config/mp-token', body: {'mp_access_token': token});
    } catch (_) {}
  }

  Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    try {
      await ApiClient.instance.patch('/financeiro/config/mp-token', body: {'mp_access_token': null});
    } catch (_) {}
  }

  Future<bool> validarToken(String token) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Cria uma preferência de pagamento e retorna o link
  Future<MpPreferencia?> criarCobranca({
    required String titulo,
    required double valor,
    String? emailPagador,
    String? descricao,
    Map<String, String>? metadados,
  }) async {
    final token = await getAccessToken();
    if (token == null) return null;

    final body = {
      'items': [
        {
          'title': titulo,
          'quantity': 1,
          'unit_price': valor,
          'currency_id': 'BRL',
          if (descricao != null) 'description': descricao,
        }
      ],
      if (emailPagador != null) 'payer': {'email': emailPagador},
      'payment_methods': {
        'installments': 1,
      },
      'statement_descriptor': 'J FIGHT',
      if (metadados != null) 'metadata': metadados,
      'notification_url': _webhookUrl,
    };

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/checkout/preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200 && res.statusCode != 201) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return MpPreferencia(
        id: data['id'] as String,
        link: (data['init_point'] ?? data['sandbox_init_point'] ?? '') as String,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> consultarStatus(String preferenciaId) async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/checkout/preferences/$preferenciaId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final payments = data['payments'] as List?;
      if (payments == null || payments.isEmpty) return null;
      return payments.last['status'] as String?;
    } catch (_) {
      return null;
    }
  }
}

class MpPreferencia {
  final String id;
  final String link;
  MpPreferencia({required this.id, required this.link});
}
