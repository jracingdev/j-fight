# Google Sign-In + Play App Signing

## Objetivo

Garantir que o login Google funcione em builds locais e na versão publicada na Play Store.

## Checklist

1. Registrar SHA-1 e SHA-256 do **upload key** no Google Cloud Console.
2. Registrar o mesmo client/config no Supabase Auth (Google provider).
3. Após ativar Play App Signing, copiar o SHA-1/SHA-256 do certificado da Google Play.
4. Adicionar esses SHAs no Google Cloud Console também.
5. Testar login no app instalado via Play Internal Testing.

## Comandos úteis

```bash
keytool -list -v -keystore upload-keystore.jks -alias upload
```

## Erro comum

- `ApiException: 10` geralmente indica SHA/client OAuth inconsistente.
