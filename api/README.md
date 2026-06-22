# API J FIGHT — PostgreSQL próprio

Backend REST que substitui o Supabase. O app Flutter consome `https://seu-servidor/api/v1`.

## Requisitos

- Node.js 18+
- PostgreSQL 14+

## Instalação no servidor

```bash
# 1. Banco
sudo -u postgres createdb jfight
sudo -u postgres createuser jfight -P
psql -U jfight -d jfight -f ../postgres/install.sql

# 2. API
cd api
cp .env.example .env
# Edite DATABASE_URL, JWT_SECRET, PUBLIC_URL, GOOGLE_CLIENT_ID

npm install
npm start
```

## Variáveis (.env)

| Variável | Descrição |
|----------|-----------|
| `DATABASE_URL` | `postgresql://user:pass@host:5432/jfight` |
| `JWT_SECRET` | Chave longa e aleatória |
| `PUBLIC_URL` | URL pública HTTPS da API (uploads e webhook MP) |
| `GOOGLE_CLIENT_ID` | Web Client ID do Google Cloud |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | Admin criado no primeiro boot |

## Endpoints principais

- `POST /api/v1/auth/login` — e-mail e senha
- `POST /api/v1/auth/register` — cadastro
- `POST /api/v1/auth/google` — `{ "id_token": "..." }`
- `GET /api/v1/auth/me` — perfil (Bearer JWT)
- `POST /api/v1/files/fotos` — upload multipart
- `POST /api/v1/webhooks/mercadopago` — webhook MP

## Deploy (PM2 + Nginx)

```bash
npm install -g pm2
pm2 start src/index.js --name jfight-api
pm2 save
```

Nginx: proxy `location /` → `http://127.0.0.1:3000` e servir `/uploads` estático.

## App Flutter

Build com URL da API:

```bash
flutter build apk --dart-define=API_BASE_URL=https://api.seudominio.com.br/api/v1
```
