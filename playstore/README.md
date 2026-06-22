# Kit de Publicação — Google Play (J FIGHT)

Este diretório reúne tudo para publicar o app `J FIGHT Academia` na Google Play.

## Passo a passo (Play Console)

1. Criar/validar conta de desenvolvedor Google Play (taxa única US$ 25).
2. Ativar **Play App Signing** no primeiro envio.
3. Gerar keystore de upload e preencher `android/key.properties` a partir de `android/key.properties.example`.
4. Gerar AAB:
   - `flutter clean`
   - `flutter pub get`
   - `flutter build appbundle --release`
5. Em **Configuração do app**:
   - Categoria e tags (`store-listing/categoria.txt`)
   - Contato (`store-listing/contato.txt`)
   - Política de privacidade (`links/urls.txt`)
6. Em **Ficha da loja principal**:
   - Título, descrição curta e completa (`store-listing/`)
   - Ícone 512x512 (`assets/icon-512.png`)
   - Feature Graphic 1024x500 (`assets/feature-graphic-1024x500.png`)
   - Screenshots (seguir `assets/screenshots/README.md`)
7. Preencher **Segurança de dados** com base em `technical/data-safety-form.md`.
8. Preencher **Classificação de conteúdo** com base em `technical/content-rating.md`.
9. Revisar permissões com `technical/permissoes.md`.
10. Subir o `.aab` em Produção (ou Teste fechado), corrigir alertas e enviar para revisão.

## Conteúdo deste kit

- `CHECKLIST.md`: auditoria técnica com status.
- `store-listing/`: textos da ficha da loja.
- `legal/`: políticas/termos em `.md` e `.html`.
- `assets/`: ícone e banner da Play.
- `technical/`: orientações técnicas e respostas pré-preenchidas.
- `links/urls.txt`: links oficiais e placeholders úteis.

## Importante

- Não incluir segredos (keystore/senhas/tokens) no Git.
- Atualizar URLs públicas caso troque o domínio de hospedagem.
- Validar o fluxo de login Google em build release antes de enviar.
