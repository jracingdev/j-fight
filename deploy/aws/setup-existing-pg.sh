#!/usr/bin/env bash
# J FIGHT — setup API usando PostgreSQL JÁ instalado (sem instalar Postgres)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
API_DIR="$ROOT/api"

: "${JFIGHT_DB_HOST:=localhost}"
: "${JFIGHT_DB_PORT:=5432}"
: "${JFIGHT_DB_USER:=jfight}"
: "${JFIGHT_DB_NAME:=jfight}"
: "${JFIGHT_DB_PASSWORD:?Defina JFIGHT_DB_PASSWORD}"
: "${JFIGHT_PUBLIC_URL:?Defina JFIGHT_PUBLIC_URL (ex: http://56.125.221.106:3000)}"
: "${JFIGHT_JWT_SECRET:?Defina JFIGHT_JWT_SECRET (openssl rand -hex 32)}"
: "${JFIGHT_GOOGLE_CLIENT_ID:=276798866114-q4s5b17hfk4ftsu3ag5hht2gu9f273r6.apps.googleusercontent.com}"
: "${JFIGHT_ADMIN_EMAIL:=admin@jfight.app}"
: "${JFIGHT_ADMIN_PASSWORD:=Demo@2026}"
: "${JFIGHT_PG_SUPERUSER:=postgres}"

echo "==> J FIGHT — Postgres existente em $JFIGHT_DB_HOST"

# Node.js 20
if ! command -v node &>/dev/null; then
  echo "==> Instalando Node.js 20..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

if ! command -v pm2 &>/dev/null; then
  echo "==> Instalando PM2..."
  sudo npm install -g pm2
fi

echo "==> Criando usuário/banco (se não existir)..."
sudo -u "$JFIGHT_PG_SUPERUSER" psql -tc "SELECT 1 FROM pg_roles WHERE rolname='$JFIGHT_DB_USER'" | grep -q 1 || \
  sudo -u "$JFIGHT_PG_SUPERUSER" psql -c "CREATE USER $JFIGHT_DB_USER WITH PASSWORD '$JFIGHT_DB_PASSWORD';"
sudo -u "$JFIGHT_PG_SUPERUSER" psql -tc "SELECT 1 FROM pg_database WHERE datname='$JFIGHT_DB_NAME'" | grep -q 1 || \
  sudo -u "$JFIGHT_PG_SUPERUSER" psql -c "CREATE DATABASE $JFIGHT_DB_NAME OWNER $JFIGHT_DB_USER;"
sudo -u "$JFIGHT_PG_SUPERUSER" psql -c "GRANT ALL PRIVILEGES ON DATABASE $JFIGHT_DB_NAME TO $JFIGHT_DB_USER;" 2>/dev/null || true

DATABASE_URL="postgresql://${JFIGHT_DB_USER}:${JFIGHT_DB_PASSWORD}@${JFIGHT_DB_HOST}:${JFIGHT_DB_PORT}/${JFIGHT_DB_NAME}"

echo "==> Aplicando schema..."
export PGPASSWORD="$JFIGHT_DB_PASSWORD"
psql "$DATABASE_URL" -f "$ROOT/postgres/install.sql"

echo "==> Configurando API..."
cat > "$API_DIR/.env" <<EOF
DATABASE_URL=$DATABASE_URL
JWT_SECRET=$JFIGHT_JWT_SECRET
JWT_EXPIRES_IN=30d
PORT=3000
PUBLIC_URL=${JFIGHT_PUBLIC_URL%/}
UPLOAD_DIR=$API_DIR/uploads
GOOGLE_CLIENT_ID=$JFIGHT_GOOGLE_CLIENT_ID
ADMIN_EMAIL=$JFIGHT_ADMIN_EMAIL
ADMIN_PASSWORD=$JFIGHT_ADMIN_PASSWORD
ADMIN_NOME=Administrador J FIGHT
EOF

cd "$API_DIR"
npm install --omit=dev
mkdir -p uploads/fotos

pm2 delete jfight-api 2>/dev/null || true
pm2 start src/index.js --name jfight-api
pm2 save
pm2 startup systemd -u "$USER" --hp "$HOME" 2>/dev/null | tail -1 | bash || true

echo ""
echo "✅ Pronto!"
echo "   Health local:  curl http://127.0.0.1:3000/health"
echo "   Health externo: curl ${JFIGHT_PUBLIC_URL%/}/health"
echo "   Admin: $JFIGHT_ADMIN_EMAIL / $JFIGHT_ADMIN_PASSWORD"
echo ""
echo "⚠️  Abra a porta 3000 no Security Group da AWS (ou configure Nginx na porta 80)."
