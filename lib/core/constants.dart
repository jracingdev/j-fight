// ============================================================
// J FIGHT â€” Constantes do App (projeto demonstraÃ§Ã£o)
// ============================================================

const String appVersion = '1.1.0';
const String appBuild = '5';
const String appName = 'J FIGHT';

/// RepositÃ³rio GitHub do projeto.
const String githubRepoUrl = 'https://github.com/jracingdev/j-fight.git';

/// Site / loja pÃºblica (GitHub Pages).
const String webAppUrl = 'https://jracingdev.github.io/j-fight/';
/// Link da loja (mesma URL da home na web).
const String lojaPublicaWebUrl = webAppUrl;
const String privacyPolicyUrl = 'https://jracingdev.github.io/j-fight/politica-privacidade.html';
const String termsOfUseUrl = 'https://jracingdev.github.io/j-fight/termos-de-uso.html';

// Academia (dados fictÃ­cios para demonstraÃ§Ã£o)
const String academiaFundacao = '2024';
const String academiaCredenciada = 'ACADEMIA DE ARTES MARCIAIS';
const String academiaCredencial = 'DEMONSTRAÃ‡ÃƒO';
const String professorNome = 'INSTRUTOR DEMO';
const String professorGraduacao = 'FAIXA PRETA';
const String professorRegistro = 'DEMO-0001';
const String professorTelefone = '5521982336975';
const String professorTelefoneExibicao = '(21) 98233-6975';
const String professorInstagram = 'jfight.academy';
const String studioInstagram = 'jfight.studio';

// Pagamento (dados fictÃ­cios)
const String pixKey = 'demo@jfight.app';
const String pixNome = 'J FIGHT Academia';

/// Google Sign-In nativo (Android/iOS). Mesmo Client ID do Supabase â†’ Auth â†’ Google.
/// Build: --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com
const String googleWebClientIdEnv = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue: '276798866114-q4s5b17hfk4ftsu3ag5hht2gu9f273r6.apps.googleusercontent.com',
);

// Desenvolvedor
const String developerNome = 'JRacing Dev';
const String developerUrl = 'https://jracing.dev.br';
const String developerEmail = 'contato@jracing.dev.br';
const String supportEmail = developerEmail;
