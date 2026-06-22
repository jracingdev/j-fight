#!/usr/bin/env bash
# J FIGHT — setup API + Postgres no Ubuntu (EC2)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
API_DIR="$ROOT/api"

: "${JFIGHT_DB_HOST:=localhost}"
: "${JFIGHT_DB_PORT:=5432}"
: "${JFIGHT_DB_USER:=jfight}"
: "${JFIGHT_DB_NAME:=jfight}"
: "${JFIGHT_DB_PASSWORD:?Defina JFIGHT_DB_PASSWORD}"
: "${JFIGHT_PUBLIC_URL:?Defina JFIGHT_PUBLIC_URL (ex: https://api.seudominio.com.br)}"
: "${JFIGHT_JWT_SECRET:?Defina JFIGHT_JWT_SECRET (openssl rand -hex 32)}"
: "${JFIGHT_GOOGLE_CLIENT_ID:=}"
: "${JFIGHT_ADMIN_EMAIL:=admin@jfight.app}"
: "${JFIGHT_ADMIN_PASSWORD:=Demo@2026}"
: "${JFIGHT_INSTALL_LOCAL_PG:=auto}"

echo "==> J FIGHT deploy — $ROOT"

# Node.js 20
if ! command -v node &>/dev/null; then
  echo "==> Instalando Node.js 20..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# PM2
if ! command -v pm2 &>/dev/null; then
  echo "==> Instalando PM2..."
  sudo npm install -g pm2
fi

# PostgreSQL local (opcional)
if [[ "$JFIGHT_INSTALL_LOCAL_PG" == "auto" ]]; then
  if [[ "$JFIGHT_DB_HOST" == "localhost" || "$JFIGHT_DB_HOST" == "127.0.0.1" ]]; then
    if ! command -v psql &>/dev/null; then
      echo "==> Instalando PostgreSQL..."
      sudo apt-get update
      sudo apt-get install -y postgresql postgresql-contrib
    fi
    JFIGHT_INSTALL_LOCAL_PG=yes
  else
    JFIGHT_INSTALL_LOCAL_PG=no
  fi
fi

if [[ "$JFIGHT_INSTALL_LOCAL_PG" == "yes" ]]; then
  echo "==> Configurando banco local..."
  sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='$JFIGHT_DB_USER'" | grep -q 1 || \
    sudo -u postgres psql -c "CREATE USER $JFIGHT_DB_USER WITH PASSWORD '$JFIGHT_DB_PASSWORD';"
  sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='$JFIGHT_DB_NAME'" | grep -q 1 || \
    sudo -u postgres psql -c "CREATE DATABASE $JFIGHT_DB_NAME OWNER $JFIGHT_DB_USER;"
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $JFIGHT_DB_NAME TO $JFIGHT_DB_USER;"
fi

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

echo "==> Iniciando PM2..."
pm2 delete jfight-api 2>/dev/null || true
pm2 start src/index.js --name jfight-api
pm2 save
pm2 startup systemd -u "$USER" --hp "$HOME" 2>/dev/null | tail -1 | bash || true

echo ""
echo "✅ API rodando em http://127.0.0.1:3000"
echo "   Configure Nginx + HTTPS: deploy/aws/README.md (Passo 4)"
echo "   Health: curl http://127.0.0.1:3000/health"
echo "   Admin: $JFIGHT_ADMIN_EMAIL / $JFIGHT_ADMIN_PASSWORD"
