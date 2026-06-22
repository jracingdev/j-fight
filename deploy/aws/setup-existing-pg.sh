#!/usr/bin/env bash
# J FIGHT — setup API usando PostgreSQL JÁ instalado (aaPanel / AWS)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
API_DIR="$ROOT/api"

: "${JFIGHT_DB_HOST:=localhost}"
: "${JFIGHT_DB_PORT:=5432}"
: "${JFIGHT_DB_USER:=jfight}"
: "${JFIGHT_DB_NAME:=jfight}"
: "${JFIGHT_DB_PASSWORD:?Defina JFIGHT_DB_PASSWORD}"
: "${JFIGHT_PUBLIC_URL:?Defina JFIGHT_PUBLIC_URL}"
: "${JFIGHT_JWT_SECRET:?Defina JFIGHT_JWT_SECRET (openssl rand -hex 32)}"
: "${JFIGHT_GOOGLE_CLIENT_ID:=276798866114-q4s5b17hfk4ftsu3ag5hht2gu9f273r6.apps.googleusercontent.com}"
: "${JFIGHT_ADMIN_EMAIL:=admin@jfight.app}"
: "${JFIGHT_ADMIN_PASSWORD:=Demo@2026}"
: "${JFIGHT_PG_SUPERUSER:=postgres}"
: "${JFIGHT_SKIP_DB_CREATE:=0}"
: "${JFIGHT_PSQL_BIN:=}"

find_psql() {
  if [[ -n "$JFIGHT_PSQL_BIN" && -x "$JFIGHT_PSQL_BIN" ]]; then
    echo "$JFIGHT_PSQL_BIN"
    return 0
  fi
  if command -v psql &>/dev/null; then
    command -v psql
    return 0
  fi
  local candidate
  for candidate in \
    /www/server/pgsql/bin/psql \
    /www/server/postgresql/bin/psql \
    /usr/lib/postgresql/*/bin/psql \
    /usr/pgsql-*/bin/psql; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

echo "==> J FIGHT — Postgres em $JFIGHT_DB_HOST:$JFIGHT_DB_PORT"

# Node.js 20
if ! command -v node &>/dev/null; then
  echo "==> Instalando Node.js 20..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
  sudo apt-get install -y nodejs
fi

if ! command -v pm2 &>/dev/null; then
  echo "==> Instalando PM2..."
  sudo npm install -g pm2
fi

PSQL="$(find_psql || true)"
if [[ -z "$PSQL" ]]; then
  echo "==> psql não encontrado — instalando postgresql-client..."
  sudo apt-get update
  sudo apt-get install -y postgresql-client
  PSQL="$(find_psql || true)"
fi

if [[ -z "$PSQL" ]]; then
  echo ""
  echo "❌ Não foi possível encontrar o psql."
  echo "   Crie o banco pelo aaPanel (Database → PostgreSQL):"
  echo "     banco: $JFIGHT_DB_NAME  usuário: $JFIGHT_DB_USER"
  echo "   Depois rode o SQL em postgres/install.sql pelo phpPgAdmin do aaPanel"
  echo "   e execute só a parte da API:"
  echo "     cd $API_DIR && npm install && pm2 start src/index.js --name jfight-api"
  exit 1
fi

echo "==> Usando psql: $PSQL"

if [[ "$JFIGHT_SKIP_DB_CREATE" != "1" ]]; then
  echo "==> Criando usuário/banco (se não existir)..."
  if sudo -u "$JFIGHT_PG_SUPERUSER" "$PSQL" -tc "SELECT 1 FROM pg_roles WHERE rolname='$JFIGHT_DB_USER'" 2>/dev/null | grep -q 1; then
    echo "    Usuário $JFIGHT_DB_USER já existe"
  else
    sudo -u "$JFIGHT_PG_SUPERUSER" "$PSQL" -c "CREATE USER $JFIGHT_DB_USER WITH PASSWORD '$JFIGHT_DB_PASSWORD';" \
      || echo "    ⚠️  Crie o usuário $JFIGHT_DB_USER manualmente no aaPanel"
  fi
  if sudo -u "$JFIGHT_PG_SUPERUSER" "$PSQL" -tc "SELECT 1 FROM pg_database WHERE datname='$JFIGHT_DB_NAME'" 2>/dev/null | grep -q 1; then
    echo "    Banco $JFIGHT_DB_NAME já existe"
  else
    sudo -u "$JFIGHT_PG_SUPERUSER" "$PSQL" -c "CREATE DATABASE $JFIGHT_DB_NAME OWNER $JFIGHT_DB_USER;" \
      || echo "    ⚠️  Crie o banco $JFIGHT_DB_NAME manualmente no aaPanel"
  fi
else
  echo "==> Pulando criação de banco (JFIGHT_SKIP_DB_CREATE=1)"
fi

DATABASE_URL="postgresql://${JFIGHT_DB_USER}:${JFIGHT_DB_PASSWORD}@${JFIGHT_DB_HOST}:${JFIGHT_DB_PORT}/${JFIGHT_DB_NAME}"

echo "==> Aplicando schema..."
export PGPASSWORD="$JFIGHT_DB_PASSWORD"
"$PSQL" "$DATABASE_URL" -f "$ROOT/postgres/install.sql"

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
echo "   curl http://127.0.0.1:3000/health"
echo "   Admin: $JFIGHT_ADMIN_EMAIL / $JFIGHT_ADMIN_PASSWORD"
