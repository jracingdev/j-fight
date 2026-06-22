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
| Logo | `assets/images/logo.png` |

## Configuração Supabase

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
