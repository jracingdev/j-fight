# J FIGHT

App Flutter de gestão de academia de artes marciais — **projeto demonstração**.

| O quê | URL |
|-------|-----|
| Repositório | https://github.com/jracingdev/j-fight.git |
| Web (GitHub Pages) | https://jracingdev.github.io/j-fight/ |
| API + Postgres | AWS EC2 (ver guia abaixo) |

## Deploy completo (app + web)

**Guia passo a passo:** [`deploy/DEPLOY-APP-E-WEB.md`](deploy/DEPLOY-APP-E-WEB.md)

Resumo:
- **AWS:** PostgreSQL + API Node (`api/`) + HTTPS com subdomínio
- **GitHub Pages:** site Flutter web
- **APK:** build no PC apontando para a mesma API

```powershell
# No PC, após API no ar com HTTPS:
$env:JFIGHT_API_BASE = "https://api.seudominio.com.br"
.\deploy\aws\build-apk-servidor.ps1
.\deploy\aws\build-web-github-pages.ps1
.\deploy\aws\publicar-github-pages.ps1
```

## Dados de demonstração

No servidor (PostgreSQL), após `postgres/install.sql`:

```bash
psql "postgresql://jfight:SENHA@localhost:5432/jfight" -f supabase_demo_data.sql
psql "postgresql://jfight:SENHA@localhost:5432/jfight" -f supabase_loja_catalogo.sql
```

Login admin: **admin@jfight.app** / **Demo@2026**

## Executar local (desenvolvimento)

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Mais detalhes: [`API_SETUP.md`](API_SETUP.md) · Servidor `56.125.221.106`: [`deploy/aws/SERVIDOR-56.125.221.106.md`](deploy/aws/SERVIDOR-56.125.221.106.md)

