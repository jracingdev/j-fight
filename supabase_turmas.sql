-- ============================================================
-- J FIGHT — Turmas (execute após supabase_setup.sql)
-- ============================================================

create table if not exists public.turmas (
  id uuid default gen_random_uuid() primary key,
  nome text not null,
  horario text not null,
  dias_semana text[] default '{}',
  tipo text default 'mista',
  ativa boolean default true,
  created_at timestamptz default now()
);

alter table public.turmas enable row level security;

drop policy if exists "Todos veem turmas" on public.turmas;
drop policy if exists "Admin gerencia turmas" on public.turmas;

create policy "Todos veem turmas" on public.turmas for select using (true);
create policy "Admin gerencia turmas" on public.turmas for all using (public.is_admin());

create table if not exists public.aluno_turmas (
  id uuid default gen_random_uuid() primary key,
  aluno_id uuid references public.alunos(id) on delete cascade,
  turma_id uuid references public.turmas(id) on delete cascade,
  data_inicio text,
  observacao text,
  unique(aluno_id, turma_id)
);

alter table public.aluno_turmas enable row level security;

drop policy if exists "Admin gerencia aluno_turmas" on public.aluno_turmas;
drop policy if exists "Aluno vê próprias turmas" on public.aluno_turmas;

create policy "Admin gerencia aluno_turmas" on public.aluno_turmas for all using (public.is_admin());
create policy "Aluno vê próprias turmas" on public.aluno_turmas for select
  using (aluno_id in (
    select id from public.alunos
    where email = (select email from auth.users where id = auth.uid())
  ));

insert into public.turmas (nome, horario, tipo, dias_semana)
select v.nome, v.horario, v.tipo, v.dias_semana
from (values
  ('Turma Mista Manhã'::text, '07:30'::text, 'mista'::text, '{}'::text[]),
  ('Turma Mista Noite', '20:00', 'mista', '{}'),
  ('Turma Baby', '18:00', 'baby', '{}'),
  ('Turma Infantil', '19:00', 'infantil', '{}'),
  ('Turma Kids', '18:00', 'kids', '{}'),
  ('Turma Kids Avançado', '18:40', 'kids', '{}')
) as v(nome, horario, tipo, dias_semana)
where not exists (select 1 from public.turmas t where t.nome = v.nome and t.horario = v.horario);

select 'Turmas configuradas!' as status;
