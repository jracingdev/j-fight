# Deploy J FIGHT API na AWS (Ubuntu EC2)

Guia passo a passo para subir **PostgreSQL + API** no seu servidor Amazon.

## Pré-requisitos

- EC2 Ubuntu 22.04/24.04 (ou similar)
- PostgreSQL já instalado **ou** instale com o script
- Domínio apontando para o IP (ex.: `api.jfight.seudominio.com`) — recomendado para HTTPS
- Portas no Security Group:
  - **22** SSH
  - **80** HTTP (Certbot)
  - **443** HTTPS
  - **5432** Postgres — **somente rede interna** (não abrir para 0.0.0.0)

---

## Passo 1 — Conectar no servidor

```bash
ssh -i sua-chave.pem ubuntu@SEU_IP_EC2
```

---

## Passo 2 — Clonar o projeto

```bash
sudo mkdir -p /opt/jfight
sudo chown $USER:$USER /opt/jfight
cd /opt/jfight
git clone https://github.com/jracingdev/j-fight.git .
```

---

## Passo 3 — Configurar variáveis e rodar o script

Edite as variáveis abaixo **antes** de executar:

```bash
export JFIGHT_DB_PASSWORD='SuaSenhaForte123!'
export JFIGHT_PUBLIC_URL='https://api.seudominio.com.br'
export JFIGHT_JWT_SECRET="$(openssl rand -hex 32)"
export JFIGHT_GOOGLE_CLIENT_ID='276798866114-q4s5b17hfk4ftsu3ag5hht2gu9f273r6.apps.googleusercontent.com'
# Se o Postgres já existe em outro host:
# export JFIGHT_DB_HOST='localhost'
# export JFIGHT_DB_USER='jfight'
# export JFIGHT_DB_NAME='jfight'

chmod +x deploy/aws/setup.sh
./deploy/aws/setup.sh
```

O script:
1. Instala Node.js 20 e PM2
2. Cria usuário/banco `jfight` (se não existir)
3. Executa `postgres/install.sql`
4. Configura `api/.env`
5. Sobe a API com PM2 na porta 3000

---

## Passo 4 — Nginx + HTTPS (Let's Encrypt)

```bash
sudo apt install -y nginx certbot python3-certbot-nginx

sudo cp deploy/aws/nginx-api.conf.template /etc/nginx/sites-available/jfight-api
sudo sed -i 's/API_DOMINIO/api.seudominio.com.br/g' /etc/nginx/sites-available/jfight-api
sudo ln -sf /etc/nginx/sites-available/jfight-api /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

sudo certbot --nginx -d api.seudominio.com.br
```

Teste: `curl https://api.seudominio.com.br/health`

---

## Passo 5 — Dados demo (opcional)

```bash
cd /opt/jfight
psql "postgresql://jfight:SUA_SENHA@localhost:5432/jfight" -f supabase_demo_data.sql
psql "postgresql://jfight:SUA_SENHA@localhost:5432/jfight" -f supabase_loja_catalogo.sql
```

> Os scripts `supabase_*.sql` ainda funcionam no Postgres; ignore referências a `auth.users` nos dados demo (use login `admin@jfight.app` criado pela API).

---

## Passo 6 — Build do app apontando para a API

No seu PC:

```bash
cd ct_sm_bjj
flutter build apk \
  --dart-define=API_BASE_URL=https://api.seudominio.com.br/api/v1 \
  --dart-define=API_PUBLIC_URL=https://api.seudominio.com.br \
  --dart-define=GOOGLE_WEB_CLIENT_ID=276798866114-q4s5b17hfk4ftsu3ag5hht2gu9f273r6.apps.googleusercontent.com
```

Login demo: **admin@jfight.app** / senha definida em `ADMIN_PASSWORD` no `.env` (padrão `Demo@2026`).

---

## Passo 7 — Mercado Pago

No painel MP → Webhooks:

```
https://api.seudominio.com.br/api/v1/webhooks/mercadopago
```

---

## Comandos úteis

```bash
pm2 status
pm2 logs jfight-api
pm2 restart jfight-api

# Atualizar após git pull
cd /opt/jfight && git pull && cd api && npm install && pm2 restart jfight-api
```

## Postgres já existente (RDS ou outro host)

Não rode a parte de criação de usuário local. Apenas:

```bash
psql "postgresql://USER:PASS@HOST:5432/jfight" -f postgres/install.sql
```

E no `api/.env`:

```
DATABASE_URL=postgresql://USER:PASS@HOST:5432/jfight
```
