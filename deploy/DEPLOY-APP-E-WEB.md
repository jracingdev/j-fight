# J FIGHT — App + Web funcionando (guia completo)

Este guia deixa **APK Android** e **site no GitHub Pages** apontando para o **mesmo backend** na AWS.

---

## Visão geral (o que vai onde)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  ONDE          │  O QUÊ                                                 │
├────────────────┼────────────────────────────────────────────────────────┤
│  AWS EC2       │  PostgreSQL (dados) + API Node (api/) + Nginx + HTTPS  │
│  56.125.221.106│  IP público do servidor                                │
├────────────────┼────────────────────────────────────────────────────────┤
│  GitHub Pages  │  Site Flutter web (só arquivos estáticos)              │
│  (navegador)   │  https://jracingdev.github.io/j-fight/                 │
├────────────────┼────────────────────────────────────────────────────────┤
│  Celular       │  APK Android instalado                                 │
├────────────────┼────────────────────────────────────────────────────────┤
│  Seu PC        │  Build do APK e build web + push gh-pages              │
│  (Windows)     │                                                        │
├────────────────┼────────────────────────────────────────────────────────┤
│  Console AWS   │  Security Group (portas 22, 80, 443)                   │
├────────────────┼────────────────────────────────────────────────────────┤
│  aaPanel       │  Terminal, Postgres, Nginx, SSL (opcional visual)      │
└────────────────┴────────────────────────────────────────────────────────┘
```

**Regra importante:** o app **nunca** conecta direto no PostgreSQL. Sempre:

`App ou Web  →  API (AWS)  →  PostgreSQL (AWS)`

**Regra para a web:** GitHub Pages é **HTTPS**. A API também precisa ser **HTTPS**, senão o navegador bloqueia. Por isso você precisa de um **subdomínio** (ex.: `api.jracing.dev.br`) com certificado SSL no servidor.

---

# PARTE 1 — AWS (servidor 56.125.221.106)

> **Onde:** navegador AWS + terminal SSH **ou** aaPanel → Terminal

## 1.1 Console AWS (navegador)

1. Acesse [AWS Console](https://console.aws.amazon.com) → **EC2** → sua instância.
2. Aba **Security** → **Security Group** → **Edit inbound rules**.
3. Adicione:

| Tipo | Porta | Origem | Para quê |
|------|-------|--------|----------|
| SSH | 22 | Seu IP (ou 0.0.0.0/0 com cuidado) | Acesso terminal |
| HTTP | 80 | 0.0.0.0/0 | Nginx + Certbot |
| HTTPS | 443 | 0.0.0.0/0 | API com SSL (obrigatório para web) |

4. **Não** abra a porta **5432** (Postgres) para a internet.

---

## 1.2 DNS — subdomínio para a API (obrigatório para web)

> **Onde:** painel do seu registrador de domínio (ex.: onde está `jracing.dev.br`)

Crie um registro **A**:

| Nome | Tipo | Valor |
|------|------|-------|
| `api` | A | `56.125.221.106` |

Resultado: `https://api.jracing.dev.br` → seu servidor.

*(Troque pelo domínio que você tiver. Sem domínio, o **APK** funciona com IP; a **web no Pages** não.)*

Aguarde 5–30 minutos para propagar. Teste: `ping api.seudominio.com.br`

---

## 1.3 Banco PostgreSQL

> **Onde:** **aaPanel → Database → PostgreSQL** *ou* **terminal SSH**

### Opção A — aaPanel (visual)

1. Database → PostgreSQL → Add database  
   - Nome: `jfight`  
   - Usuário: `jfight`  
   - Senha: anote em local seguro  

### Opção B — já existe banco

Anote: host (`localhost`), usuário, senha, nome do banco.

---

## 1.4 API + schema (terminal)

> **Onde:** **SSH** ou **aaPanel → Terminal**

```bash
ssh -i sua-chave.pem ubuntu@56.125.221.106
```

```bash
sudo mkdir -p /opt/jfight && sudo chown $USER:$USER /opt/jfight
cd /opt/jfight
git clone https://github.com/jracingdev/j-fight.git .
# se já clonou: git pull
```

Defina as variáveis (ajuste senha e domínio):

```bash
export JFIGHT_DB_PASSWORD='SuaSenhaForte123!'
export JFIGHT_PUBLIC_URL='https://api.jracing.dev.br'
export JFIGHT_JWT_SECRET="$(openssl rand -hex 32)"
# se criou banco pelo aaPanel com outros nomes:
# export JFIGHT_DB_USER='jfight'
# export JFIGHT_DB_NAME='jfight'
```

Instale:

```bash
chmod +x deploy/aws/setup-existing-pg.sh
./deploy/aws/setup-existing-pg.sh
```

Teste **no servidor**:

```bash
curl http://127.0.0.1:3000/health
```

Esperado: `{"ok":true,"app":"jfight-api"}`

---

## 1.5 Nginx + HTTPS (obrigatório para web)

> **Onde:** **aaPanel → Website** *ou* terminal

### Opção aaPanel (recomendado se já usa o painel)

1. **Website** → **Add site**  
   - Domínio: `api.jracing.dev.br`  
   - PHP: desligado / site estático  

2. No site → **Reverse proxy** → destino: `http://127.0.0.1:3000`  

3. **SSL** → Let's Encrypt → aplicar em `api.jracing.dev.br`  

4. Teste no PC:

```bash
curl https://api.jracing.dev.br/health
```

### Opção terminal (Nginx manual)

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
sudo cp /opt/jfight/deploy/aws/nginx-api.conf.template /etc/nginx/sites-available/jfight-api
sudo sed -i 's/API_DOMINIO/api.jracing.dev.br/g' /etc/nginx/sites-available/jfight-api
sudo ln -sf /etc/nginx/sites-available/jfight-api /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d api.jracing.dev.br
```

---

## 1.6 Dados demo (opcional)

> **Onde:** terminal no servidor

```bash
export PGPASSWORD='SuaSenhaForte123!'
psql "postgresql://jfight:$PGPASSWORD@localhost:5432/jfight" -f /opt/jfight/supabase_demo_data.sql
psql "postgresql://jfight:$PGPASSWORD@localhost:5432/jfight" -f /opt/jfight/supabase_loja_catalogo.sql
```

Login admin: **admin@jfight.app** / **Demo@2026**

---

## 1.7 Mercado Pago (opcional)

> **Onde:** painel Mercado Pago → Webhooks

URL:

```
https://api.jracing.dev.br/api/v1/webhooks/mercadopago
```

---

# PARTE 2 — APK Android (celular)

> **Onde:** **seu PC Windows** (PowerShell, pasta do projeto)

## 2.1 Build

Abra PowerShell:

```powershell
cd "D:\J FIGHT\ct_sm_bjj"
```

Edite a URL da API no script **ou** passe variável:

```powershell
# Com domínio HTTPS (recomendado — mesmo da web):
$env:JFIGHT_API_BASE = "https://api.jracing.dev.br"
.\deploy\aws\build-apk-servidor.ps1

# OU só IP (funciona no APK, não use para web):
# $env:JFIGHT_API_BASE = "http://56.125.221.106:3000"
# .\deploy\aws\build-apk-servidor.ps1
```

APK gerado em:

```
build\app\outputs\flutter-apk\app-release.apk
```

## 2.2 Instalar no celular

```powershell
flutter install
# ou copie o APK e instale manualmente
```

## 2.3 Testar no app

1. Abra J FIGHT  
2. Login: `admin@jfight.app` / `Demo@2026`  
3. Confira alunos, turmas, loja  

Se der erro de conexão: API não está no ar ou URL errada no build.

---

# PARTE 3 — Web GitHub Pages (navegador)

> **Onde:** **seu PC Windows** (build) + **GitHub** (hospedagem automática)

Site final: **https://jracingdev.github.io/j-fight/**

## 3.1 Build web com URL da API

```powershell
cd "D:\J FIGHT\ct_sm_bjj"

# OBRIGATÓRIO: API em HTTPS (mesmo domínio do passo 1.5)
$env:JFIGHT_API_BASE = "https://api.jracing.dev.br"
.\deploy\aws\build-web-github-pages.ps1
```

## 3.2 Publicar no GitHub Pages

```powershell
.\deploy\aws\publicar-github-pages.ps1
```

Isso envia `build/web` para a branch `gh-pages`.

## 3.3 Configurar GitHub (uma vez)

> **Onde:** navegador → GitHub → repo `jracingdev/j-fight`

1. **Settings** → **Pages**  
2. Source: **Deploy from branch**  
3. Branch: `gh-pages` / `/ (root)`  
4. Save  

Aguarde 1–3 minutos e abra: https://jracingdev.github.io/j-fight/

## 3.4 Testar no navegador

1. Abra o site  
2. F12 → **Console** — não deve aparecer erro de "Mixed Content"  
3. Faça login com `admin@jfight.app`  

Se aparecer bloqueio HTTPS→HTTP: a API ainda não tem SSL — volte ao passo **1.5**.

---

# PARTE 4 — Google Sign-In (opcional)

> **Onde:** Google Cloud Console + build Flutter

1. Mesmo **Web Client ID** no build (`GOOGLE_WEB_CLIENT_ID`)  
2. No servidor, `GOOGLE_CLIENT_ID` no `api/.env`  
3. Na web, login Google pode ser limitado — e-mail/senha funciona sempre  

---

# Checklist final

### AWS
- [ ] Security Group: 22, 80, 443  
- [ ] DNS `api.seudominio.com` → `56.125.221.106`  
- [ ] Postgres com banco `jfight`  
- [ ] `setup-existing-pg.sh` executado  
- [ ] `curl https://api.seudominio.com/health` → ok  

### APK (PC)
- [ ] `build-apk-servidor.ps1` com `JFIGHT_API_BASE` HTTPS  
- [ ] Login admin funciona no celular  

### Web (PC + GitHub)
- [ ] `build-web-github-pages.ps1` com mesma API HTTPS  
- [ ] `publicar-github-pages.ps1` executado  
- [ ] GitHub Pages apontando para `gh-pages`  
- [ ] Login funciona em https://jracingdev.github.io/j-fight/  

---

# Resumo “onde fazer o quê”

| Tarefa | Onde |
|--------|------|
| Abrir portas firewall | **AWS Console** |
| Criar subdomínio API | **Registrador de domínio** |
| Postgres | **aaPanel** ou **terminal** |
| Instalar API (Node/PM2) | **Terminal SSH / aaPanel Terminal** |
| SSL + Nginx | **aaPanel Website** ou **terminal** |
| Build APK | **Seu PC** |
| Build web + push Pages | **Seu PC** |
| Hospedar site | **GitHub** (branch gh-pages) |
| Usar app | **Celular** |
| Usar web | **Navegador** → GitHub Pages |

---

# Atualizar depois de mudanças no código

| O quê mudou | O que refazer | Onde |
|-------------|---------------|------|
| Código Flutter | Build APK + build web + publicar Pages | PC |
| Código API (`api/`) | `git pull` + `pm2 restart jfight-api` | Servidor |
| Só dados SQL | Rodar scripts `.sql` | Servidor |

```bash
# No servidor, atualizar API:
cd /opt/jfight && git pull && cd api && npm install && pm2 restart jfight-api
```

---

# Problemas comuns

| Sintoma | Causa | Solução |
|---------|-------|---------|
| Web não loga, APK loga | API só HTTP | HTTPS no passo 1.5 |
| Mixed Content no console | API sem SSL | Certificado no Nginx |
| Connection refused | API parada ou porta fechada | `pm2 status`, Security Group |
| 401 / token | Relogar no app | Logout e login de novo |
| Postgres error | Schema não aplicado | `postgres/install.sql` |

---

**Servidor deste projeto:** `56.125.221.106`  
**Site:** https://jracingdev.github.io/j-fight/  
**API (exemplo):** https://api.jracing.dev.br/api/v1  

Substitua `api.jracing.dev.br` pelo subdomínio que você configurar.
