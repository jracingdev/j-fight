# Deploy no servidor 56.125.221.106 (PostgreSQL já instalado)

> **Guia completo app + web:** [`../DEPLOY-APP-E-WEB.md`](../DEPLOY-APP-E-WEB.md)

## 1. Security Group AWS

Libere no Security Group do EC2:

| Porta | Uso |
|-------|-----|
| 22 | SSH |
| 3000 | API (teste) — ou só 80/443 com Nginx |
| 5432 | **NÃO** abrir para internet |

## 2. SSH no servidor

```bash
ssh -i sua-chave.pem ubuntu@56.125.221.106
```

(Se o usuário for `ec2-user` no Amazon Linux, troque `ubuntu`.)

## 3. Clonar e instalar

```bash
sudo mkdir -p /opt/jfight && sudo chown $USER:$USER /opt/jfight
cd /opt/jfight
git clone https://github.com/jracingdev/j-fight.git .
git pull   # se já clonou antes

export JFIGHT_DB_PASSWORD='EscolhaUmaSenhaForte!'
export JFIGHT_PUBLIC_URL='http://56.125.221.106:3000'
export JFIGHT_JWT_SECRET="$(openssl rand -hex 32)"

chmod +x deploy/aws/setup-existing-pg.sh
./deploy/aws/setup-existing-pg.sh
```

## 4. Testar

No servidor:
```bash
curl http://127.0.0.1:3000/health
```

No seu PC:
```bash
curl http://56.125.221.106:3000/health
```

Resposta esperada: `{"ok":true,"app":"jfight-api"}`

## 5. Dados demo (opcional)

Se o `install.sql` foi aplicado antes desta correção, rode primeiro:

```bash
export PGPASSWORD='EscolhaUmaSenhaForte!'
psql -h 127.0.0.1 -p 5432 -U jfight -d jfight -f postgres/migrate_demo_schema.sql
```

Depois:

```bash
export PGPASSWORD='EscolhaUmaSenhaForte!'
psql -h 127.0.0.1 -p 5432 -U jfight -d jfight -f supabase_demo_data.sql
psql -h 127.0.0.1 -p 5432 -U jfight -d jfight -f supabase_loja_catalogo.sql
```

## 6. Build APK apontando para seu IP

```bash
flutter build apk \
  --dart-define=API_BASE_URL=http://56.125.221.106:3000/api/v1 \
  --dart-define=API_PUBLIC_URL=http://56.125.221.106:3000 \
  --dart-define=GOOGLE_WEB_CLIENT_ID=276798866114-q4s5b17hfk4ftsu3ag5hht2gu9f273r6.apps.googleusercontent.com
```

Login: **admin@jfight.app** / **Demo@2026**

## 7. Postgres com usuário diferente

Se já tiver um banco/usuário, edite antes do script:

```bash
export JFIGHT_DB_USER='seu_usuario'
export JFIGHT_DB_NAME='seu_banco'
export JFIGHT_DB_PASSWORD='sua_senha'
export JFIGHT_PG_SUPERUSER='postgres'   # ou ubuntu com peer auth
```

## 8. Nginx (recomendado depois)

Para usar porta 80 sem `:3000` no app, veja `deploy/aws/README.md` Passo 4.

Webhook Mercado Pago:
```
http://56.125.221.106:3000/api/v1/webhooks/mercadopago
```
