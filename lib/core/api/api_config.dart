/// URL base da API (PostgreSQL próprio).
/// Build: --dart-define=API_BASE_URL=https://api.seudominio.com.br/api/v1
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);

/// URL pública do servidor (uploads, webhook MP).
const String apiPublicUrl = String.fromEnvironment(
  'API_PUBLIC_URL',
  defaultValue: 'http://10.0.2.2:3000',
);
