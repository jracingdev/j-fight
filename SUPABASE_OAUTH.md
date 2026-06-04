# OAuth Google — configuração Supabase

No painel Supabase: **Authentication → URL Configuration → Redirect URLs**, adicione:

```
https://jracingdev.github.io/smbjj/
com.smbijj.ct_sm_bjj://login-callback
io.supabase.flutter://callback
```

**Site URL (web):** `https://jracingdev.github.io/smbjj/`

- **App Android:** login Google abre dentro do app e retorna pelo deep link `com.smbijj.ct_sm_bjj://login-callback`
- **Web:** login Google redireciona para o GitHub Pages e permanece na web
