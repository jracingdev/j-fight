# Permissões Android e justificativas

## Em uso no manifesto

- `android.permission.INTERNET`
  - Necessária para Supabase, autenticação, APIs e conteúdo remoto.

- `android.permission.CAMERA`
  - Necessária para scanner QR (presença/fluxos internos) e recursos de captura.

- `android.permission.USE_BIOMETRIC`
  - Necessária para login biométrico opcional.

- `android.permission.USE_FINGERPRINT`
  - Compatibilidade com dispositivos legados de biometria.

## Removidas na auditoria

- `READ_EXTERNAL_STORAGE` e `WRITE_EXTERNAL_STORAGE`
  - Removidas para reduzir risco de bloqueio/review adicional.

- `USE_FACE_LOCK`
  - Removida por não ser permissão padrão Android para publicação.

## Queries de intents

- `https/http` para abrir links externos (pagamento, suporte, páginas legais).
- `whatsapp` e pacotes WhatsApp para contato da academia.
