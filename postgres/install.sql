-- ============================================================
-- J FIGHT — PostgreSQL standalone (sem Supabase)
-- Execute no servidor: psql -U jfight -d jfight -f install.sql
-- Depois rode os scripts de dados demo se quiser.
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- Se falhar no aaPanel, peça ao admin instalar pgcrypto ou ignore (a API gera UUIDs).

-- ── Autenticação própria ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS auth_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  email_confirmed BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS usuarios (
  id UUID PRIMARY KEY REFERENCES auth_accounts(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role TEXT DEFAULT 'aluno' CHECK (role IN ('admin', 'aluno')),
  foto_url TEXT,
  aluno_id UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ── Alunos ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS alunos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  email TEXT,
  data_nascimento TEXT,
  sexo TEXT DEFAULT 'masculino',
  telefone TEXT,
  nome_responsavel TEXT,
  telefone_responsavel TEXT,
  endereco TEXT,
  cidade TEXT,
  estado TEXT,
  cep TEXT,
  faixa TEXT DEFAULT 'branca',
  grau INTEGER DEFAULT 0,
  peso NUMERIC,
  foto_url TEXT,
  ativo BOOLEAN DEFAULT true,
  cadastro_validado BOOLEAN DEFAULT false,
  valor_mensalidade NUMERIC,
  dia_vencimento INTEGER,
  desconto_percentual NUMERIC,
  observacao_financeira TEXT,
  data_inicio_aulas TEXT,
  iniciante BOOLEAN DEFAULT false,
  pro_rata_primeiro_mes BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE usuarios
  DROP CONSTRAINT IF EXISTS usuarios_aluno_id_fkey;
ALTER TABLE usuarios
  ADD CONSTRAINT usuarios_aluno_id_fkey FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE SET NULL;

-- ── Mensalidades ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS mensalidades (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  aluno_id UUID REFERENCES alunos(id) ON DELETE CASCADE,
  aluno_nome TEXT,
  mes INTEGER NOT NULL,
  ano INTEGER NOT NULL,
  valor NUMERIC NOT NULL,
  status TEXT DEFAULT 'pendente' CHECK (status IN ('pendente', 'pago', 'atrasado')),
  data_pagamento TEXT,
  observacao TEXT,
  cancelada BOOLEAN DEFAULT false,
  pro_rata BOOLEAN DEFAULT false,
  mp_preferencia_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ── Turmas ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS turmas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  horario TEXT,
  dias_semana TEXT[],
  tipo TEXT DEFAULT 'adulto',
  ativa BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS aluno_turmas (
  aluno_id UUID REFERENCES alunos(id) ON DELETE CASCADE,
  turma_id UUID REFERENCES turmas(id) ON DELETE CASCADE,
  data_inicio TEXT,
  PRIMARY KEY (aluno_id, turma_id)
);

-- ── Presenças ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS presencas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  turma_id UUID REFERENCES turmas(id) ON DELETE CASCADE,
  aluno_id UUID REFERENCES alunos(id) ON DELETE CASCADE,
  aluno_nome TEXT,
  data_aula TEXT NOT NULL,
  presente BOOLEAN DEFAULT true,
  origem TEXT DEFAULT 'chamada',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (turma_id, aluno_id, data_aula)
);

CREATE TABLE IF NOT EXISTS presenca_config (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  metodo TEXT NOT NULL DEFAULT 'chamada' CHECK (metodo IN ('chamada', 'qr_turma', 'qr_unico')),
  token_validade_minutos INT NOT NULL DEFAULT 30,
  updated_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO presenca_config (id) VALUES (1) ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS presenca_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  token TEXT NOT NULL UNIQUE,
  tipo TEXT NOT NULL CHECK (tipo IN ('turma', 'unico')),
  turma_id UUID REFERENCES turmas(id) ON DELETE CASCADE,
  data_aula TEXT NOT NULL,
  valido_ate TIMESTAMPTZ NOT NULL,
  ativo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ── Loja ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS produtos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  descricao TEXT,
  preco NUMERIC NOT NULL,
  foto_url TEXT,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS produto_variantes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  produto_id UUID REFERENCES produtos(id) ON DELETE CASCADE,
  cor TEXT,
  tamanho TEXT,
  estoque INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS pedidos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  aluno_id UUID REFERENCES alunos(id) ON DELETE SET NULL,
  aluno_nome TEXT,
  aluno_email TEXT,
  aluno_telefone TEXT,
  produto_id UUID REFERENCES produtos(id) ON DELETE SET NULL,
  produto_nome TEXT,
  variante_cor TEXT,
  variante_tamanho TEXT,
  quantidade INTEGER DEFAULT 1,
  valor_unitario NUMERIC,
  valor_total NUMERIC,
  status TEXT DEFAULT 'pendente',
  forma_pagamento TEXT,
  link_pagamento TEXT,
  pago BOOLEAN DEFAULT false,
  data_pagamento TEXT,
  codigo_rastreamento TEXT,
  transportadora TEXT,
  link_rastreamento TEXT,
  data_envio TEXT,
  data_entrega_estimada TEXT,
  observacoes TEXT,
  observacoes_admin TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ── Conteúdo ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS avisos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titulo TEXT NOT NULL,
  conteudo TEXT,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS eventos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titulo TEXT NOT NULL,
  descricao TEXT,
  data_evento TEXT,
  local TEXT,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS medalhas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  descricao TEXT,
  icone TEXT,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ── Financeiro ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS financeiro_config (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  valor_mensalidade_padrao NUMERIC,
  dia_vencimento_padrao INTEGER DEFAULT 10,
  mp_access_token TEXT,
  regras JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO financeiro_config (id) VALUES (1) ON CONFLICT DO NOTHING;

-- ── Termos ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS termos_aceites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth_accounts(id) ON DELETE SET NULL,
  nome TEXT,
  email TEXT,
  tipo TEXT NOT NULL,
  ip TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS desabilitado — a API aplica permissões no código
ALTER TABLE IF EXISTS usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS alunos DISABLE ROW LEVEL SECURITY;

SELECT 'Schema J FIGHT instalado!' AS status;
