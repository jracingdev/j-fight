/// URL base da API (PostgreSQL próprio).
/// Build release: --dart-define=API_BASE_URL=https://api.jracing.dev.br/api/v1
/// Dev local emulador: --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.jracing.dev.br/api/v1',
);

/// URL pública do servidor (uploads, webhook MP).
const String apiPublicUrl = String.fromEnvironment(
  'API_PUBLIC_URL',
  defaultValue: 'https://api.jracing.dev.br',
);
