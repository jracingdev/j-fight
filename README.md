# J FIGHT

App Flutter de gestão de academia de artes marciais — **projeto demonstração** baseado em um modelo real, com identidade visual e dados fictícios.

Repositório: https://github.com/jracingdev/j-fight.git

Web (GitHub Pages): https://jracingdev.github.io/j-fight/

## Identidade visual

| Elemento | Valor |
|----------|-------|
| Nome | **J FIGHT** |
| Cor primária | `#B91C1C` (vermelho combate) |
| Cor de fundo | `#1A1A2E` (preto grafite) |
| Cor destaque | `#F59E0B` (dourado) |
| Logo | `assets/images/logo.png` (origem: `logo dark LOGO J FIGHT.png`) |

## Dados de demonstração

Para popular o app com uma academia movimentada (53 alunos, turmas, mensalidades, presenças, medalhas, loja e pedidos):

1. No [Supabase SQL Editor](https://supabase.com/dashboard/project/zhjnxspunbtyqhlyliuw/sql), execute **`supabase_demo_data.sql`**.
2. Crie o admin em **Authentication → Users**: `admin@jfight.app` (se ainda não existir).
3. Execute **`supabase_loja_catalogo.sql`** para o catálogo da loja (14 produtos com fotos).
4. *(Opcional)* Crie 1–3 alunos demo no Auth com os mesmos e-mails do script (ex.: `demo.marcos.silva@jfight.app`, senha `Demo@2026`) para testar login de aluno.

Contas demo usam e-mails `demo.*@jfight.app`. Reexecutar o script limpa e recria os dados demo.


1. Execute `supabase_setup.sql` no SQL Editor do projeto.
2. Execute `supabase_turmas.sql` (turmas e vínculo aluno ↔ turma).
3. Opcional: `supabase_pedidos.sql` para a loja.
4. Crie o usuário admin em **Authentication → Users** (`admin@jfight.app`).

Credenciais do app estão em `lib/core/supabase_service.dart` (chave publishable — uso client-side com RLS).

## Versão atual

**1.0.0** (build 1) — fork de demonstração com rebranding J FIGHT.

## Executar

```bash
flutter pub get
flutter run
```

## Build web (GitHub Pages)

```bash
flutter build web --release --base-href "/j-fight/"
```

## Instalar no celular

```bash
flutter build apk --release
flutter install
```
