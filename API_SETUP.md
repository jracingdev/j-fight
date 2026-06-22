# J FIGHT — PostgreSQL + API própria

O app não usa mais Supabase. A arquitetura é:

```
Flutter App  →  API REST (Node.js)  →  PostgreSQL
```

## 1. Banco de dados (servidor AWS)

```bash
psql -U postgres -c "CREATE USER jfight WITH PASSWORD 'sua_senha';"
psql -U postgres -c "CREATE DATABASE jfight OWNER jfight;"
psql -U jfight -d jfight -f postgres/install.sql

# Dados demo (opcional)
psql -U jfight -d jfight -f supabase_demo_data.sql
psql -U jfight -d jfight -f supabase_loja_catalogo.sql
```

## 2. API

```bash
cd api
cp .env.example .env
# Edite: DATABASE_URL, JWT_SECRET, PUBLIC_URL, GOOGLE_CLIENT_ID

npm install
npm start
```

No primeiro boot, cria o admin (`admin@jfight.app` / senha do `.env`).

## 3. App Flutter

Defina a URL da API no build:

```bash
# Emulador Android → host da máquina
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 \
  --dart-define=API_PUBLIC_URL=http://10.0.2.2:3000

# Produção
flutter build apk \
  --dart-define=API_BASE_URL=https://api.seudominio.com.br/api/v1 \
  --dart-define=API_PUBLIC_URL=https://api.seudominio.com.br \
  --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com
```

## 4. Mercado Pago

Webhook no painel MP:

```
https://api.seudominio.com.br/api/v1/webhooks/mercadopago
```

## 5. Google Sign-In

- Mesmo **Web Client ID** do Google Cloud
- Configure `GOOGLE_CLIENT_ID` no `.env` da API
- Configure `GOOGLE_WEB_CLIENT_ID` no build Flutter

## Migração do Supabase

Se já tinha dados no Supabase, exporte com `pg_dump` das tabelas `public.*` e importe no Postgres do servidor. A tabela `auth.users` vira `auth_accounts` + `usuarios` — recrie contas ou importe com hash bcrypt.

## Deploy na AWS (EC2)

Guia completo com script automatizado: **[deploy/aws/README.md](deploy/aws/README.md)**

```bash
# No servidor Ubuntu, após git clone:
export JFIGHT_DB_PASSWORD='...'
export JFIGHT_PUBLIC_URL='https://api.seudominio.com.br'
export JFIGHT_JWT_SECRET="$(openssl rand -hex 32)"
./deploy/aws/setup.sh
```
