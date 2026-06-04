# OAuth Google — CT SM BJJ

## Supabase (Authentication → URL Configuration)

**Redirect URLs** (todas):

```
https://jracingdev.github.io/smbjj/
https://jracingdev.github.io/smbjj
io.supabase.flutter://callback
com.smbijj.ct_sm_bjj://login-callback
```

**Site URL (web):** `https://jracingdev.github.io/smbjj/`

No provedor **Google**, ative **Skip nonce check** (recomendado para login nativo no app).

---

## App Android (recomendado): login nativo

O app usa **Google Sign-In nativo** (diálogo do sistema), sem abrir o Chrome e sem depender de deep link.

### 1. Google Cloud Console

1. **APIs & Services → Credentials**
2. Copie o **Client ID** do tipo **Web application** (termina em `.apps.googleusercontent.com`)
3. Esse mesmo ID deve estar em **Supabase → Authentication → Providers → Google → Client ID**

### 2. Build do APK com o Client ID

```bash
flutter build apk --release --dart-define=GOOGLE_WEB_CLIENT_ID=SEU_CLIENT_ID_WEB.apps.googleusercontent.com
```

Ou defina em `lib/core/constants.dart` em `googleWebClientIdEnv` (apenas para testes locais; prefira `--dart-define` em produção).

### 3. Instalar o APK novo

Sem o `GOOGLE_WEB_CLIENT_ID`, o app cai no fluxo antigo (navegador + deep link), que no Android costuma falhar ao voltar.

---

## Web (GitHub Pages)

Login Google usa redirect para `https://jracingdev.github.io/smbjj/` — permanece no navegador.

---

## Fallback OAuth no app (se não houver Client ID)

- Redirect: `io.supabase.flutter://callback`
- Abre o **navegador externo**; após login, o sistema deve oferecer **Abrir no CT SM BJJ**
- `AndroidManifest.xml` já declara os intent-filters
