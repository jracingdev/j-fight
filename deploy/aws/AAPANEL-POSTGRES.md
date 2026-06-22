# aaPanel + PostgreSQL — passos quando `psql` não foi encontrado

## 1. Criar banco no aaPanel (navegador)

1. aaPanel → **Database** → **PostgreSQL** → **Add database**
2. Nome: `jfight`
3. Usuário: `jfight`
4. Senha: a mesma que você definiu em `JFIGHT_DB_PASSWORD`

## 2. No terminal SSH

```bash
# Cliente psql (se ainda não tiver)
sudo apt-get update
sudo apt-get install -y postgresql-client

# Atualizar script (após git pull no projeto)
cd /opt/jfight
git pull

# Rodar instalação (banco já criado no aaPanel)
export JFIGHT_DB_PASSWORD='SUA_SENHA'
export JFIGHT_PUBLIC_URL='http://56.125.221.106:3000'
export JFIGHT_JWT_SECRET="$(openssl rand -hex 32)"
export JFIGHT_SKIP_DB_CREATE=1

chmod +x deploy/aws/setup-existing-pg.sh
./deploy/aws/setup-existing-pg.sh
```

## 3. Se o Postgres do aaPanel usar outro caminho

```bash
export JFIGHT_PSQL_BIN=/www/server/pgsql/bin/psql
./deploy/aws/setup-existing-pg.sh
```

## 4. Testar

```bash
curl http://127.0.0.1:3000/health
pm2 logs jfight-api --lines 30
```

## 5. SQL manual (alternativa)

Se `psql` não conectar, no aaPanel abra **phpPgAdmin** ou **SQL** do banco `jfight` e cole o conteúdo de `postgres/install.sql`.

Depois só suba a API:

```bash
cd /opt/jfight/api
npm install --omit=dev
pm2 start src/index.js --name jfight-api
pm2 save
```
