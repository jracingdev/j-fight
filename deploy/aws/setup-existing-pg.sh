#!/usr/bin/env bash
# J FIGHT — setup API usando PostgreSQL JÁ instalado (aaPanel / AWS)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
API_DIR="$ROOT/api"

: "${JFIGHT_DB_HOST:=127.0.0.1}"
: "${JFIGHT_DB_PORT:=5432}"
: "${JFIGHT_DB_USER:=jfight}"
: "${JFIGHT_DB_NAME:=jfight}"
: "${JFIGHT_DB_PASSWORD:?Defina JFIGHT_DB_PASSWORD}"
: "${JFIGHT_PUBLIC_URL:?Defina JFIGHT_PUBLIC_URL}"
: "${JFIGHT_JWT_SECRET:?Defina JFIGHT_JWT_SECRET (openssl rand -hex 32)}"
: "${JFIGHT_GOOGLE_CLIENT_ID:=276798866114-q4s5b17hfk4ftsu3ag5hht2gu9f273r6.apps.googleusercontent.com}"
: "${JFIGHT_ADMIN_EMAIL:=admin@jfight.app}"
: "${JFIGHT_ADMIN_PASSWORD:=Demo@2026}"
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
    /usr/lib/postgresql/*/bin/psql; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

detect_pg_port() {
  local conf
  for conf in \
    /www/server/pgsql/data/postgresql.conf \
    /www/server/postgresql/data/postgresql.conf; do
    if [[ -f "$conf" ]]; then
      local p
      p=$(grep -E '^[[:space:]]*port[[:space:]]*=' "$conf" | tail -1 | grep -oE '[0-9]+' || true)
      if [[ -n "$p" ]]; then
        echo "$p"
        return 0
      fi
    fi
  done
  echo "5432"
}

psql_tcp() {
  local db="${1:-postgres}"
  shift || true
  export PGPASSWORD="${PGPASSWORD:-$JFIGHT_DB_PASSWORD}"
  "$PSQL" -h "$JFIGHT_DB_HOST" -p "$JFIGHT_DB_PORT" -U "$JFIGHT_DB_USER" -d "$db" "$@"
}

echo "==> J FIGHT — Postgres $JFIGHT_DB_HOST:$JFIGHT_DB_PORT"

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
  echo "==> Instalando postgresql-client..."
  sudo apt-get update
  sudo apt-get install -y postgresql-client
  PSQL="$(find_psql || true)"
fi

if [[ -z "$PSQL" ]]; then
  echo "❌ psql não encontrado. Crie o banco no aaPanel e rode o SQL manualmente."
  exit 1
fi

if [[ "$JFIGHT_DB_PORT" == "5432" ]]; then
  JFIGHT_DB_PORT="$(detect_pg_port)"
fi

echo "==> psql: $PSQL | porta: $JFIGHT_DB_PORT"

if [[ "$JFIGHT_SKIP_DB_CREATE" != "1" ]]; then
  echo "==> Dica: se falhar, crie banco/usuário no aaPanel e use JFIGHT_SKIP_DB_CREATE=1"
fi

echo "==> Testando conexão com o banco..."
if ! psql_tcp "$JFIGHT_DB_NAME" -c "SELECT 1" &>/dev/null; then
  echo ""
  echo "❌ Não conectou em $JFIGHT_DB_HOST:$JFIGHT_DB_PORT banco=$JFIGHT_DB_NAME user=$JFIGHT_DB_USER"
  echo ""
  echo "Faça no aaPanel → Database → PostgreSQL:"
  echo "  - Banco: $JFIGHT_DB_NAME"
  echo "  - Usuário: $JFIGHT_DB_USER"
  echo "  - Senha: (a mesma de JFIGHT_DB_PASSWORD)"
  echo "  - Permissão: All privileges"
  echo ""
  echo "Verifique se o Postgres está rodando:"
  echo "  ss -tlnp | grep postgres"
  echo "  sudo /etc/init.d/pgsql status"
  echo ""
  echo "Teste manual:"
  echo "  PGPASSWORD='***' psql -h $JFIGHT_DB_HOST -p $JFIGHT_DB_PORT -U $JFIGHT_DB_USER -d $JFIGHT_DB_NAME -c 'SELECT 1'"
  exit 1
fi

DATABASE_URL="postgresql://${JFIGHT_DB_USER}:${JFIGHT_DB_PASSWORD}@${JFIGHT_DB_HOST}:${JFIGHT_DB_PORT}/${JFIGHT_DB_NAME}"

echo "==> Aplicando schema..."
export PGPASSWORD="$JFIGHT_DB_PASSWORD"
"$PSQL" -h "$JFIGHT_DB_HOST" -p "$JFIGHT_DB_PORT" -U "$JFIGHT_DB_USER" -d "$JFIGHT_DB_NAME" -f "$ROOT/postgres/install.sql"

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

echo ""
echo "✅ Pronto!"
echo "   curl http://127.0.0.1:3000/health"
echo "   Admin: $JFIGHT_ADMIN_EMAIL / $JFIGHT_ADMIN_PASSWORD"
