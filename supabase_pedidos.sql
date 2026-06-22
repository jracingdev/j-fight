-- ============================================================
-- J FIGHT — Tabela de Pedidos da Loja
-- Execute no SQL Editor do Supabase
-- ============================================================

create table if not exists public.pedidos (
  id uuid default gen_random_uuid() primary key,
  -- Comprador
  aluno_id uuid references public.alunos(id) on delete set null,
  aluno_nome text not null,
  aluno_email text,
  aluno_telefone text,
  -- Produto
  produto_id uuid references public.produtos(id) on delete set null,
  produto_nome text not null,
  variante_cor text,
  variante_tamanho text,
  quantidade integer default 1,
  valor_unitario numeric not null,
  valor_total numeric not null,
  -- Status do pedido
  status text default 'pendente'
    check (status in ('pendente','confirmado','preparando','enviado','entregue','cancelado')),
  -- Pagamento
  forma_pagamento text default 'whatsapp'
    check (forma_pagamento in ('whatsapp','mercadopago','pix','dinheiro')),
  link_pagamento text,
  pago boolean default false,
  data_pagamento text,
  -- Entrega / Rastreamento
  codigo_rastreamento text,
  transportadora text,
  link_rastreamento text,
  data_envio text,
  data_entrega_estimada text,
  -- Extras
  observacoes text,
  observacoes_admin text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS
alter table public.pedidos enable row level security;

drop policy if exists "Admin gerencia pedidos" on public.pedidos;
drop policy if exists "Aluno vê próprios pedidos" on public.pedidos;
drop policy if exists "Aluno cria próprio pedido" on public.pedidos;

create policy "Admin gerencia pedidos" on public.pedidos
  for all using (public.is_admin());

create policy "Aluno vê próprios pedidos" on public.pedidos
  for select using (lower(trim(aluno_email)) = lower(trim(auth.email())));

create policy "Aluno cria próprio pedido" on public.pedidos
  for insert with check (lower(trim(aluno_email)) = lower(trim(auth.email())));

select 'Tabela pedidos criada!' as status;
