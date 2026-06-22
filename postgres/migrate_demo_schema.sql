-- ============================================================
-- J FIGHT — Alinha schema PostgreSQL ao app / scripts demo
-- Execute no servidor (banco já criado com install.sql):
--   psql -h 127.0.0.1 -p 5432 -U jfight -d jfight -f postgres/migrate_demo_schema.sql
-- Depois:
--   psql ... -f supabase_demo_data.sql
--   psql ... -f supabase_loja_catalogo.sql
-- ============================================================

BEGIN;

-- ── Alunos (campos financeiros) ──────────────────────────────
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS bolsista BOOLEAN DEFAULT false;
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS percentual_bolsa NUMERIC DEFAULT 0;
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS grupo_familiar TEXT;
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS cpf_pagante TEXT;
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS cobranca_ativa BOOLEAN DEFAULT true;
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS data_inicio_cobranca TEXT;
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS data_interrupcao_cobranca TEXT;
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS justificativa_interrupcao TEXT;
ALTER TABLE alunos ADD COLUMN IF NOT EXISTS valor_mensalidade_custom NUMERIC;

-- ── Produtos (loja) ──────────────────────────────────────────
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS categoria TEXT DEFAULT 'kimono';
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS youtube_url TEXT;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS prazo_entrega TEXT DEFAULT 'imediato';
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS prazo_dias INTEGER DEFAULT 0;
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS prazo_data TEXT;

UPDATE produtos SET categoria = 'kimono' WHERE categoria IS NULL;
UPDATE produtos SET prazo_entrega = 'imediato' WHERE prazo_entrega IS NULL;
UPDATE produtos SET prazo_dias = 0 WHERE prazo_dias IS NULL;

-- ── Avisos ───────────────────────────────────────────────────
ALTER TABLE avisos ADD COLUMN IF NOT EXISTS tipo TEXT DEFAULT 'info';
ALTER TABLE avisos ADD COLUMN IF NOT EXISTS link_url TEXT;
ALTER TABLE avisos ADD COLUMN IF NOT EXISTS fonte TEXT;

UPDATE avisos SET conteudo = '' WHERE conteudo IS NULL;
UPDATE avisos SET tipo = 'info' WHERE tipo IS NULL;

-- ── Eventos ──────────────────────────────────────────────────
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'eventos' AND column_name = 'data_evento'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'eventos' AND column_name = 'data'
  ) THEN
    ALTER TABLE eventos RENAME COLUMN data_evento TO data;
  END IF;
END $$;

ALTER TABLE eventos ADD COLUMN IF NOT EXISTS data TEXT;
ALTER TABLE eventos ADD COLUMN IF NOT EXISTS tipo TEXT DEFAULT 'campeonato';
ALTER TABLE eventos ADD COLUMN IF NOT EXISTS organizador TEXT;
ALTER TABLE eventos ADD COLUMN IF NOT EXISTS link_url TEXT;
ALTER TABLE eventos ADD COLUMN IF NOT EXISTS hora_inicio TEXT;
ALTER TABLE eventos ADD COLUMN IF NOT EXISTS hora_fim TEXT;

UPDATE eventos SET data = COALESCE(data, '') WHERE data IS NULL;
UPDATE eventos SET tipo = 'campeonato' WHERE tipo IS NULL;

-- ── Medalhas (schema errado no install antigo) ───────────────
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'medalhas' AND column_name = 'nome'
  ) THEN
    DROP TABLE medalhas;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS medalhas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  aluno_id UUID REFERENCES alunos(id) ON DELETE CASCADE,
  aluno_nome TEXT NOT NULL,
  titulo TEXT NOT NULL,
  tipo TEXT DEFAULT 'ouro' CHECK (tipo IN ('ouro', 'prata', 'bronze', 'outro')),
  data_conquista TEXT,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ── Mensalidades ─────────────────────────────────────────────
ALTER TABLE mensalidades ADD COLUMN IF NOT EXISTS valor_base NUMERIC;
ALTER TABLE mensalidades ADD COLUMN IF NOT EXISTS cancelada BOOLEAN DEFAULT false;
ALTER TABLE mensalidades ADD COLUMN IF NOT EXISTS pro_rata BOOLEAN DEFAULT false;
ALTER TABLE mensalidades ADD COLUMN IF NOT EXISTS mp_preferencia_id TEXT;
ALTER TABLE mensalidades ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

CREATE UNIQUE INDEX IF NOT EXISTS mensalidades_aluno_mes_ano_uidx
  ON mensalidades (aluno_id, mes, ano)
  WHERE (cancelada = false OR cancelada IS NULL);

-- ── Financeiro (colunas extras usadas pelo app) ──────────────
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS valor_adulto NUMERIC DEFAULT 110;
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS valor_menor NUMERIC DEFAULT 80;
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS desconto_2o_familiar_percent NUMERIC DEFAULT 10;
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS desconto_3o_familiar_percent NUMERIC DEFAULT 15;
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS desconto_mesmo_pagante_percent NUMERIC DEFAULT 5;
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS dia_vencimento INTEGER DEFAULT 10;
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS regras_extras JSONB DEFAULT '[]'::jsonb;
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS pro_rata_ativo BOOLEAN DEFAULT true;
ALTER TABLE financeiro_config ADD COLUMN IF NOT EXISTS mp_access_token TEXT;

-- ── Turmas (seed para demo) ──────────────────────────────────
INSERT INTO turmas (nome, horario, tipo, dias_semana)
SELECT v.nome, v.horario, v.tipo, v.dias_semana
FROM (VALUES
  ('Turma Mista Manhã'::text, '07:30'::text, 'mista'::text, '{}'::text[]),
  ('Turma Mista Noite', '20:00', 'mista', '{}'),
  ('Turma Baby', '18:00', 'baby', '{}'),
  ('Turma Infantil', '19:00', 'infantil', '{}'),
  ('Turma Kids', '18:00', 'kids', '{}'),
  ('Turma Kids Avançado', '18:40', 'kids', '{}')
) AS v(nome, horario, tipo, dias_semana)
WHERE NOT EXISTS (
  SELECT 1 FROM turmas t WHERE t.nome = v.nome AND t.horario = v.horario
);

COMMIT;

SELECT 'Schema alinhado ao app — rode supabase_demo_data.sql e supabase_loja_catalogo.sql' AS status;
