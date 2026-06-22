# Checklist de Pré-requisitos (Google Play 2026)

| Item | Status | Observação |
|---|---|---|
| `applicationId` / package `com.jracingdev.jfight` | PASS | Confirmado em `android/app/build.gradle.kts` e `MainActivity.kt`. |
| `compileSdk` | PASS | `36` configurado. |
| `targetSdk` | PASS | Usa `flutter.targetSdkVersion` (alinhado ao Flutter atual). |
| `minSdk` | PASS | `23` (compatível com libs usadas). |
| `versionCode` / `versionName` | PASS | Vêm de `pubspec` (`1.7.22+53`) via Flutter Gradle. |
| `android:exported` activity principal | PASS | `MainActivity` com `android:exported="true"`. |
| Deep links / callback OAuth | PASS | Schemes `com.jracingdev.jfight://login-callback` e `io.supabase.flutter://callback`. |
| Permissões Android justificadas | PASS | Mantidas `INTERNET`, `CAMERA`, `USE_BIOMETRIC`, `USE_FINGERPRINT`. Removidas permissões desnecessárias de storage e `USE_FACE_LOCK`. |
| App signing release | PASS | Adicionado signing config por `key.properties` com fallback debug; criado `android/key.properties.example`. |
| Política de privacidade com URL pública | PASS | Link adicionado na tela Sobre e documentado para Play: `https://jracingdev.github.io/j-fight/politica-privacidade.html`. |
| Termos de uso públicos | PASS | URL preparada: `https://jracingdev.github.io/j-fight/termos-de-uso.html`. |
| Declaração de coleta de dados | PASS | Arquivo pronto em `technical/data-safety-form.md` (Supabase, Google, biometria, Mercado Pago, WhatsApp). |
| Suporte 64-bit | PASS | Flutter Android gera ARM64 por padrão em AAB. |
| R8/ProGuard | PASS* | Release com minify desativado (configuração estável para envio inicial). |

## Pendências operacionais (fora de código)

- Criar keystore de upload real e `android/key.properties` local.
- Gerar AAB release e testar login Google + pagamentos em ambiente real.
- Capturar screenshots finais conforme guideline da Play.
