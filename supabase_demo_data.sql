-- ============================================================
-- J FIGHT — Dados de demonstração (academia movimentada)
-- Execute no SQL Editor do Supabase (role postgres — ignora RLS)
-- Pré-requisito: supabase_setup.sql, turmas, financeiro, presencas, pedidos
-- ============================================================
-- Remove dados demo anteriores (e-mails demo.%@jfight.app)
-- Senha sugerida para contas demo criadas no Auth: Demo@2026
-- ============================================================

begin;

-- ── Limpeza demo anterior ───────────────────────────────────
delete from public.presencas
where aluno_id in (select id from public.alunos where email like 'demo.%@jfight.app');

delete from public.medalhas
where aluno_id in (select id from public.alunos where email like 'demo.%@jfight.app');

delete from public.mensalidades
where aluno_id in (select id from public.alunos where email like 'demo.%@jfight.app');

delete from public.aluno_turmas
where aluno_id in (select id from public.alunos where email like 'demo.%@jfight.app');

delete from public.pedidos
where aluno_email like 'demo.%@jfight.app' or observacoes_admin = 'demo_seed';

delete from public.alunos where email like 'demo.%@jfight.app';

delete from public.produto_variantes
where produto_id in (select id from public.produtos where descricao = 'demo_seed');

delete from public.produtos where descricao = 'demo_seed';

delete from public.avisos where fonte = 'demo_seed';
delete from public.eventos where organizador = 'demo_seed';

-- ── Turmas: dias da semana ──────────────────────────────────
update public.turmas set dias_semana = array['segunda','quarta','sexta'], ativa = true
where nome = 'Turma Mista Manhã';

update public.turmas set dias_semana = array['segunda','terca','quarta','quinta','sexta'], ativa = true
where nome = 'Turma Mista Noite';

update public.turmas set dias_semana = array['terca','quinta'], ativa = true
where nome = 'Turma Baby';

update public.turmas set dias_semana = array['segunda','quarta'], ativa = true
where nome = 'Turma Infantil';

update public.turmas set dias_semana = array['segunda','quarta','sexta'], ativa = true
where nome = 'Turma Kids';

update public.turmas set dias_semana = array['terca','quinta','sabado'], ativa = true
where nome = 'Turma Kids Avançado';

-- ── Alunos demo (48 atletas + 5 pendentes validação) ────────
insert into public.alunos (
  nome, email, data_nascimento, sexo, telefone, cidade, estado,
  faixa, grau, ativo, cadastro_validado, cobranca_ativa,
  grupo_familiar, bolsista, percentual_bolsa, data_inicio_aulas, iniciante
) values
-- Adultos / mista noite (faixas variadas)
('Marcos Silva',           'demo.marcos.silva@jfight.app',       '15/03/1992', 'masculino', '21990010001', 'Rio de Janeiro', 'RJ', 'azul',   2, true, true,  true, 'familia-silva', false, 0,  '2024-01', false),
('Ana Paula Silva',        'demo.ana.silva@jfight.app',          '22/07/1994', 'feminino',  '21990010002', 'Rio de Janeiro', 'RJ', 'roxa',   1, true, true,  true, 'familia-silva', false, 0,  '2023-06', false),
('Ricardo Silva',          'demo.ricardo.silva@jfight.app',      '10/11/1988', 'masculino', '21990010003', 'Rio de Janeiro', 'RJ', 'marrom', 0, true, true,  true, 'familia-silva', false, 0,  '2020-03', false),
('Fernanda Costa',         'demo.fernanda.costa@jfight.app',     '05/09/1990', 'feminino',  '21990010004', 'Niterói',        'RJ', 'azul',   3, true, true,  true, null,            false, 0,  '2024-08', false),
('Bruno Oliveira',         'demo.bruno.oliveira@jfight.app',     '18/01/1985', 'masculino', '21990010005', 'Rio de Janeiro', 'RJ', 'preta',  2, true, true,  true, null,            false, 0,  '2018-02', false),
('Camila Santos',          'demo.camila.santos@jfight.app',      '30/06/1993', 'feminino',  '21990010006', 'São Gonçalo',    'RJ', 'azul',   1, true, true,  true, 'familia-santos',false, 0,  '2025-01', false),
('Diego Santos',           'demo.diego.santos@jfight.app',       '14/02/1991', 'masculino', '21990010007', 'São Gonçalo',    'RJ', 'roxa',   0, true, true,  true, 'familia-santos',false, 0,  '2022-09', false),
('Juliana Mendes',         'demo.juliana.mendes@jfight.app',     '08/12/1996', 'feminino',  '21990010008', 'Rio de Janeiro', 'RJ', 'branca', 4, true, true,  true, null,            false, 0,  '2025-11', true),
('Thiago Almeida',         'demo.thiago.almeida@jfight.app',     '25/04/1987', 'masculino', '21990010009', 'Duque de Caxias','RJ', 'marrom', 1, true, true,  true, null,            false, 0,  '2019-05', false),
('Patrícia Lima',          'demo.patricia.lima@jfight.app',      '03/08/1995', 'feminino',  '21990010010', 'Rio de Janeiro', 'RJ', 'azul',   0, true, true,  true, null,            false, 0,  '2024-03', false),
('Gustavo Pereira',        'demo.gustavo.pereira@jfight.app',    '17/10/1989', 'masculino', '21990010011', 'Rio de Janeiro', 'RJ', 'roxa',   3, true, true,  true, null,            false, 0,  '2021-07', false),
('Larissa Rocha',          'demo.larissa.rocha@jfight.app',      '12/05/1997', 'feminino',  '21990010012', 'Niterói',        'RJ', 'branca', 2, true, true,  true, null,            false, 0,  '2025-06', true),
('Felipe Martins',         'demo.felipe.martins@jfight.app',     '29/09/1986', 'masculino', '21990010013', 'Rio de Janeiro', 'RJ', 'preta',  1, true, true,  true, null,            false, 0,  '2016-01', false),
('Amanda Ferreira',        'demo.amanda.ferreira@jfight.app',    '21/02/1994', 'feminino',  '21990010014', 'Rio de Janeiro', 'RJ', 'azul',   2, true, true,  true, null,            true,  50, '2023-03', false),
('Rodrigo Barbosa',        'demo.rodrigo.barbosa@jfight.app',    '07/07/1991', 'masculino', '21990010015', 'Belford Roxo',   'RJ', 'roxa',   2, true, true,  true, null,            false, 0,  '2020-11', false),
('Vanessa Carvalho',       'demo.vanessa.carvalho@jfight.app',    '16/03/1998', 'feminino',  '21990010016', 'Rio de Janeiro', 'RJ', 'branca', 1, true, true,  true, null,            false, 0,  '2026-01', true),
('Leonardo Souza',         'demo.leonardo.souza@jfight.app',     '11/11/1990', 'masculino', '21990010017', 'Rio de Janeiro', 'RJ', 'azul',   4, true, true,  true, null,            false, 0,  '2022-04', false),
('Beatriz Nunes',          'demo.beatriz.nunes@jfight.app',      '04/04/1996', 'feminino',  '21990010018', 'São João de Meriti','RJ','marrom',0, true, true,  true, null,           false, 0,  '2019-09', false),
('Eduardo Gomes',          'demo.eduardo.gomes@jfight.app',      '28/08/1988', 'masculino', '21990010019', 'Rio de Janeiro', 'RJ', 'preta',  0, true, true,  true, null,            false, 0,  '2017-06', false),
('Carla Dias',             'demo.carla.dias@jfight.app',         '19/01/1993', 'feminino',  '21990010020', 'Rio de Janeiro', 'RJ', 'azul',   1, true, true,  true, null,            false, 0,  '2024-05', false),
-- Manhã
('Paulo Henrique Ribeiro', 'demo.paulo.ribeiro@jfight.app',      '06/06/1984', 'masculino', '21990010021', 'Rio de Janeiro', 'RJ', 'marrom', 2, true, true,  true, null,            false, 0,  '2018-08', false),
('Mônica Araújo',          'demo.monica.araujo@jfight.app',       '13/12/1991', 'feminino',  '21990010022', 'Rio de Janeiro', 'RJ', 'roxa',   1, true, true,  true, null,            false, 0,  '2021-02', false),
('Henrique Vieira',        'demo.henrique.vieira@jfight.app',    '02/02/1987', 'masculino', '21990010023', 'Niterói',        'RJ', 'azul',   3, true, true,  true, null,            false, 0,  '2023-10', false),
('Tatiane Moura',          'demo.tatiane.moura@jfight.app',      '27/07/1995', 'feminino',  '21990010024', 'Rio de Janeiro', 'RJ', 'branca', 3, true, true,  true, null,            false, 0,  '2025-09', true),
-- Kids / infantil
('Lucas Ferreira (Kids)',  'demo.lucas.kids@jfight.app',         '15/04/2014', 'masculino', '21990010025', 'Rio de Janeiro', 'RJ', 'amarela',0, true, true,  true, 'familia-ferreira',false,0,'2024-02',false),
('Sofia Ferreira (Kids)',  'demo.sofia.kids@jfight.app',         '20/09/2016', 'feminino',  '21990010026', 'Rio de Janeiro', 'RJ', 'laranja',0, true, true,  true, 'familia-ferreira',false,0,'2025-03',true),
('Miguel Costa (Kids)',    'demo.miguel.kids@jfight.app',        '08/11/2013', 'masculino', '21990010027', 'Niterói',        'RJ', 'verde',  1, true, true,  true, null,            false, 0,  '2023-01', false),
('Isabela Rocha (Kids)',   'demo.isabela.kids@jfight.app',       '03/03/2015', 'feminino',  '21990010028', 'Rio de Janeiro', 'RJ', 'amarela',1, true, true,  true, null,            false, 0,  '2024-06', false),
('Arthur Lima (Kids)',     'demo.arthur.kids@jfight.app',        '22/08/2012', 'masculino', '21990010029', 'Rio de Janeiro', 'RJ', 'verde',  2, true, true,  true, null,            false, 0,  '2022-05', false),
('Helena Dias (Kids)',     'demo.helena.kids@jfight.app',        '10/01/2017', 'feminino',  '21990010030', 'Rio de Janeiro', 'RJ', 'cinza',  0, true, true,  true, null,            false, 0,  '2025-08', true),
('Pedro Alves (Kids Av.)', 'demo.pedro.kidsav@jfight.app',       '14/06/2011', 'masculino', '21990010031', 'Rio de Janeiro', 'RJ', 'verde',  3, true, true,  true, null,            false, 0,  '2021-03', false),
('Laura Nunes (Kids Av.)', 'demo.laura.kidsav@jfight.app',       '05/10/2010', 'feminino',  '21990010032', 'São Gonçalo',    'RJ', 'azul',   0, true, true,  true, null,            false, 0,  '2020-07', false),
-- Baby / infantil
('Benício Melo (Baby)',    'demo.benicio.baby@jfight.app',       '18/02/2019', 'masculino', '21990010033', 'Rio de Janeiro', 'RJ', 'branca', 0, true, true,  true, null,            false, 0,  '2025-04', true),
('Alice Teixeira (Inf.)',  'demo.alice.infantil@jfight.app',     '25/11/2018', 'feminino',  '21990010034', 'Rio de Janeiro', 'RJ', 'branca', 1, true, true,  true, null,            false, 0,  '2024-09', false),
('Davi Cardoso (Inf.)',    'demo.davi.infantil@jfight.app',      '07/05/2019', 'masculino', '21990010035', 'Niterói',        'RJ', 'cinza',  0, true, true,  true, null,            false, 0,  '2025-07', true),
-- Mais adultos
('Rafael Monteiro',        'demo.rafael.monteiro@jfight.app',    '09/09/1992', 'masculino', '21990010036', 'Rio de Janeiro', 'RJ', 'azul',   2, true, true,  true, null,            false, 0,  '2023-04', false),
('Gabriela Pinto',         'demo.gabriela.pinto@jfight.app',     '31/01/1997', 'feminino',  '21990010037', 'Rio de Janeiro', 'RJ', 'branca', 4, true, true,  true, null,            false, 0,  '2025-12', true),
('Vinícius Correia',       'demo.vinicius.correia@jfight.app',   '23/03/1989', 'masculino', '21990010038', 'Duque de Caxias','RJ', 'roxa',   2, true, true,  true, null,            false, 0,  '2020-02', false),
('Natália Freitas',        'demo.natalia.freitas@jfight.app',    '14/07/1994', 'feminino',  '21990010039', 'Rio de Janeiro', 'RJ', 'azul',   1, true, true,  true, null,            false, 0,  '2024-11', false),
('André Lopes',            'demo.andre.lopes@jfight.app',        '01/12/1986', 'masculino', '21990010040', 'Rio de Janeiro', 'RJ', 'marrom', 1, true, true,  true, null,            false, 0,  '2018-12', false),
('Renata Cavalcanti',      'demo.renata.cavalcanti@jfight.app',  '26/05/1998', 'feminino',  '21990010041', 'Rio de Janeiro', 'RJ', 'branca', 2, true, true,  true, null,            false, 0,  '2026-02', true),
('Igor Batista',           'demo.igor.batista@jfight.app',       '19/08/1990', 'masculino', '21990010042', 'Belford Roxo',   'RJ', 'azul',   0, true, true,  true, null,            false, 0,  '2025-02', true),
('Priscila Ramos',         'demo.priscila.ramos@jfight.app',     '11/04/1993', 'feminino',  '21990010043', 'Rio de Janeiro', 'RJ', 'roxa',   0, true, true,  true, null,            false, 0,  '2022-08', false),
('Caio Moreira',           'demo.caio.moreira@jfight.app',       '06/10/1987', 'masculino', '21990010044', 'Rio de Janeiro', 'RJ', 'preta',  3, true, true,  true, null,            false, 0,  '2015-04', false),
('Débora Campos',          'demo.debora.campos@jfight.app',      '02/06/1996', 'feminino',  '21990010045', 'Niterói',        'RJ', 'azul',   2, true, true,  true, null,            false, 0,  '2024-07', false),
('Mateus Azevedo',         'demo.mateus.azevedo@jfight.app',     '17/03/1991', 'masculino', '21990010046', 'Rio de Janeiro', 'RJ', 'roxa',   1, true, true,  true, null,            false, 0,  '2021-10', false),
('Luana Farias',           'demo.luana.farias@jfight.app',       '28/12/1995', 'feminino',  '21990010047', 'Rio de Janeiro', 'RJ', 'branca', 3, true, true,  true, null,            false, 0,  '2025-10', true),
('João Victor Rezende',    'demo.joaovictor.rezende@jfight.app', '09/07/1988', 'masculino', '21990010048', 'Rio de Janeiro', 'RJ', 'marrom', 0, true, true,  true, null,            false, 0,  '2019-01', false),
-- Pendentes de validação (admin vê fila)
('Novo Aluno Demo 1',      'demo.pendente1@jfight.app',          '01/01/2000', 'masculino', '21990010049', 'Rio de Janeiro', 'RJ', 'branca', 0, true, false, true, null,            false, 0,  '2026-03', true),
('Novo Aluno Demo 2',      'demo.pendente2@jfight.app',          '01/01/2001', 'feminino',  '21990010050', 'Rio de Janeiro', 'RJ', 'branca', 0, true, false, true, null,            false, 0,  '2026-03', true),
('Novo Aluno Demo 3',      'demo.pendente3@jfight.app',          '01/01/1999', 'masculino', '21990010051', 'Niterói',        'RJ', 'branca', 0, true, false, true, null,            false, 0,  '2026-03', true),
('Novo Aluno Demo 4',      'demo.pendente4@jfight.app',          '01/01/2002', 'feminino',  '21990010052', 'Rio de Janeiro', 'RJ', 'branca', 0, true, false, true, null,            false, 0,  '2026-03', true),
('Novo Aluno Demo 5',      'demo.pendente5@jfight.app',          '01/01/1998', 'masculino', '21990010053', 'Rio de Janeiro', 'RJ', 'branca', 0, true, false, true, null,            false, 0,  '2026-03', true);

-- ── Matrículas em turmas ────────────────────────────────────
insert into public.aluno_turmas (aluno_id, turma_id, data_inicio)
select a.id, t.id, '2025-01-15'
from public.alunos a
join public.turmas t on t.nome = 'Turma Mista Noite'
where a.email in (
  'demo.marcos.silva@jfight.app','demo.ana.silva@jfight.app','demo.ricardo.silva@jfight.app',
  'demo.fernanda.costa@jfight.app','demo.bruno.oliveira@jfight.app','demo.camila.santos@jfight.app',
  'demo.diego.santos@jfight.app','demo.juliana.mendes@jfight.app','demo.thiago.almeida@jfight.app',
  'demo.patricia.lima@jfight.app','demo.gustavo.pereira@jfight.app','demo.larissa.rocha@jfight.app',
  'demo.felipe.martins@jfight.app','demo.amanda.ferreira@jfight.app','demo.rodrigo.barbosa@jfight.app',
  'demo.vanessa.carvalho@jfight.app','demo.leonardo.souza@jfight.app','demo.beatriz.nunes@jfight.app',
  'demo.eduardo.gomes@jfight.app','demo.carla.dias@jfight.app','demo.rafael.monteiro@jfight.app',
  'demo.gabriela.pinto@jfight.app','demo.vinicius.correia@jfight.app','demo.natalia.freitas@jfight.app',
  'demo.andre.lopes@jfight.app','demo.renata.cavalcanti@jfight.app','demo.igor.batista@jfight.app',
  'demo.priscila.ramos@jfight.app','demo.caio.moreira@jfight.app','demo.debora.campos@jfight.app',
  'demo.mateus.azevedo@jfight.app','demo.luana.farias@jfight.app','demo.joaovictor.rezende@jfight.app'
)
on conflict (aluno_id, turma_id) do nothing;

insert into public.aluno_turmas (aluno_id, turma_id, data_inicio)
select a.id, t.id, '2025-01-15'
from public.alunos a
join public.turmas t on t.nome = 'Turma Mista Manhã'
where a.email in (
  'demo.paulo.ribeiro@jfight.app','demo.monica.araujo@jfight.app',
  'demo.henrique.vieira@jfight.app','demo.tatiane.moura@jfight.app'
)
on conflict do nothing;

insert into public.aluno_turmas (aluno_id, turma_id, data_inicio)
select a.id, t.id, '2025-01-15'
from public.alunos a
join public.turmas t on t.nome = 'Turma Kids'
where a.email like 'demo.%.kids@jfight.app'
on conflict do nothing;

insert into public.aluno_turmas (aluno_id, turma_id, data_inicio)
select a.id, t.id, '2025-01-15'
from public.alunos a
join public.turmas t on t.nome = 'Turma Kids Avançado'
where a.email like 'demo.%.kidsav@jfight.app'
on conflict do nothing;

insert into public.aluno_turmas (aluno_id, turma_id, data_inicio)
select a.id, t.id, '2025-01-15'
from public.alunos a
join public.turmas t on t.nome = 'Turma Baby'
where a.email like 'demo.%.baby@jfight.app'
on conflict do nothing;

insert into public.aluno_turmas (aluno_id, turma_id, data_inicio)
select a.id, t.id, '2025-01-15'
from public.alunos a
join public.turmas t on t.nome = 'Turma Infantil'
where a.email like 'demo.%.infantil@jfight.app'
on conflict do nothing;

-- ── Mensalidades (últimos 7 meses) ──────────────────────────
insert into public.mensalidades (aluno_id, aluno_nome, mes, ano, valor, valor_base, status, data_pagamento, pro_rata)
select
  a.id,
  a.nome,
  m.mes,
  m.ano,
  case
    when a.bolsista then round((case when a.email like '%kids%' or a.email like '%baby%' or a.email like '%infantil%' then 80 else 110 end) * (1 - coalesce(a.percentual_bolsa,0)/100.0), 2)
    when a.email like '%kids%' or a.email like '%baby%' or a.email like '%infantil%' then 80
    else 110
  end as valor,
  case when a.email like '%kids%' or a.email like '%baby%' or a.email like '%infantil%' then 80 else 110 end,
  case
    when m.ano = 2026 and m.mes = 3 then case when random() < 0.4 then 'pendente' when random() < 0.7 then 'atrasado' else 'pago' end
    when m.ano = 2026 and m.mes = 2 then case when random() < 0.15 then 'pendente' when random() < 0.25 then 'atrasado' else 'pago' end
    else case when random() < 0.08 then 'atrasado' when random() < 0.12 then 'pendente' else 'pago' end
  end,
  case when random() < 0.85 then to_char(make_date(m.ano, m.mes, 5 + floor(random()*8)::int), 'YYYY-MM-DD') else null end,
  a.iniciante and m.ano = 2026 and m.mes = 1
from public.alunos a
cross join (values
  (9,2025),(10,2025),(11,2025),(12,2025),
  (1,2026),(2,2026),(3,2026)
) as m(mes, ano)
where a.email like 'demo.%@jfight.app'
  and a.cadastro_validado = true
  and a.cobranca_ativa = true
on conflict do nothing;

-- ── Presenças (últimas 10 semanas, ~75% frequência) ─────────
insert into public.presencas (turma_id, aluno_id, aluno_nome, data_aula, presente, origem)
select
  at.turma_id,
  a.id,
  a.nome,
  to_char(current_date - (gs * 7 + floor(random() * 3)::int), 'YYYY-MM-DD'),
  true,
  case when random() < 0.35 then 'qr' else 'chamada' end
from public.alunos a
join public.aluno_turmas at on at.aluno_id = a.id
cross join generate_series(0, 9) gs
where a.email like 'demo.%@jfight.app'
  and a.cadastro_validado = true
  and random() < 0.78
on conflict do nothing;

-- ── Medalhas (ranking de competições) ───────────────────────
insert into public.medalhas (aluno_id, aluno_nome, titulo, tipo, data_conquista, ativo)
select a.id, a.nome, v.titulo, v.tipo, v.data_c, true
from public.alunos a
cross join lateral (values
  ('Open RJ 2025 — Categoria Leve', 'ouro',   '2025-08-12'),
  ('Copa Zona Norte 2025',         'prata',  '2025-05-20'),
  ('Interno J FIGHT — Absoluto',   'bronze', '2025-11-03')
) as v(titulo, tipo, data_c)
where a.email in (
  'demo.bruno.oliveira@jfight.app','demo.felipe.martins@jfight.app','demo.caio.moreira@jfight.app',
  'demo.marcos.silva@jfight.app','demo.ana.silva@jfight.app','demo.gustavo.pereira@jfight.app',
  'demo.pedro.kidsav@jfight.app','demo.laura.kidsav@jfight.app','demo.miguel.kids@jfight.app'
)
and random() < 0.55
limit 45;

-- ── Avisos ──────────────────────────────────────────────────
insert into public.avisos (titulo, conteudo, tipo, link_url, fonte, ativo) values
('Aulão de guarda — sábado 09h', 'Treino aberto para todas as faixas. Traga kimono extra e garrafa de água.', 'importante', null, 'demo_seed', true),
('Inscrições abertas — Copa J FIGHT', 'Campeonato interno dia 28/03. Fale com a recepção para garantir sua categoria.', 'info', 'https://jracingdev.github.io/j-fight/', 'demo_seed', true),
('Horário especial — feriado', 'Na próxima segunda não haverá turma da manhã. Noite normal às 20h.', 'alerta', null, 'demo_seed', true),
('Nova turma Kids Avançado', 'Vagas limitadas para faixa verde+. Avaliação com o professor às quintas.', 'info', null, 'demo_seed', true),
('Loja com estoque de kimonos A1–A4', 'Kimonos J FIGHT disponíveis para retirada imediata. Confira na aba Loja.', 'info', null, 'demo_seed', true),
('Seminário de passagem de guarda', 'Convidado especial — 04/04, das 14h às 17h. Inscrição R$ 80.', 'importante', null, 'demo_seed', true),
('Ranking de presença — fevereiro', 'Parabéns aos destaques do mês! Confira o quadro de medalhas no app.', 'info', null, 'demo_seed', true),
('BJJ News: IBJJF Rio', 'Resultados da etapa carioca disponíveis. Três atletas J FIGHT no pódio.', 'bjj_news', 'https://ibjjf.com/', 'demo_seed', true),
('Lembrete: mensalidade até dia 10', 'Evite atraso. PIX e Mercado Pago disponíveis no app.', 'alerta', null, 'demo_seed', true),
('Treino somente kimono — quarta', 'Sem no-gi nesta semana por preparação para competição.', 'info', null, 'demo_seed', true);

-- ── Eventos (calendário) ────────────────────────────────────
insert into public.eventos (titulo, data, tipo, descricao, local, organizador, link_url) values
('Graduação semestral',        to_char(current_date + 18, 'YYYY-MM-DD'), 'graduacao',  'Cerimônia de faixas para kids e adultos.', 'J FIGHT Academia', 'demo_seed', null),
('Copa J FIGHT Interna',       to_char(current_date + 32, 'YYYY-MM-DD'), 'campeonato', 'Inscrições até 7 dias antes do evento.', 'Ginásio Municipal', 'demo_seed', null),
('Seminário Passagem de Guarda',to_char(current_date + 12, 'YYYY-MM-DD'),'seminario',  '3 horas de técnica com faixa preta convidada.', 'J FIGHT Academia', 'demo_seed', null),
('Aulão Beneficente',          to_char(current_date + 45, 'YYYY-MM-DD'), 'aulao',      'Treino aberto — doações de alimentos.', 'J FIGHT Academia', 'demo_seed', null),
('Open CBJJ — Etapa RJ',       to_char(current_date + 60, 'YYYY-MM-DD'), 'campeonato', 'Equipe J FIGHT confirmada com 22 atletas.', 'Tijuca Tênis Clube', 'demo_seed', 'https://cbjj.com.br/'),
('Treino especial No-Gi',      to_char(current_date + 7,  'YYYY-MM-DD'), 'aulao',      'Quinta 19h30 — rashguard obrigatório.', 'J FIGHT Academia', 'demo_seed', null),
('Reunião de pais — Kids',     to_char(current_date + 5,  'YYYY-MM-DD'), 'outro',      'Alinhamento de competições e graduação.', 'Sala 2', 'demo_seed', null),
('Workshop Defesa Pessoal',    to_char(current_date - 14, 'YYYY-MM-DD'), 'seminario',  'Evento realizado com 35 participantes.', 'J FIGHT Academia', 'demo_seed', null),
('Campeonato Estadual 2025',   to_char(current_date - 45, 'YYYY-MM-DD'), 'campeonato', '8 medalhas conquistadas pela equipe.', 'Niterói', 'demo_seed', null);

-- ── Loja: use supabase_loja_catalogo.sql (catálogo com fotos reais) ──
-- Os blocos abaixo de produtos/pedidos foram movidos para supabase_loja_catalogo.sql

-- ── Vincular usuários demo (se já existirem no Auth) ────────
update public.usuarios u
set aluno_id = a.id
from public.alunos a
where lower(u.email) = lower(a.email)
  and a.email like 'demo.%@jfight.app'
  and u.aluno_id is null;

commit;

select
  (select count(*) from public.alunos where email like 'demo.%@jfight.app') as alunos_demo,
  (select count(*) from public.alunos where email like 'demo.%@jfight.app' and cadastro_validado = false) as pendentes_validacao,
  (select count(*) from public.mensalidades m join public.alunos a on a.id = m.aluno_id where a.email like 'demo.%@jfight.app') as mensalidades,
  (select count(*) from public.presencas pr join public.alunos a on a.id = pr.aluno_id where a.email like 'demo.%@jfight.app') as presencas,
  (select count(*) from public.medalhas md join public.alunos a on a.id = md.aluno_id where a.email like 'demo.%@jfight.app') as medalhas,
  (select count(*) from public.pedidos where observacoes_admin = 'demo_seed' or aluno_email like 'demo.%@jfight.app') as pedidos,
  'Dados demo J FIGHT aplicados! Crie contas em Auth para login de aluno (senha sugerida: Demo@2026)' as status;
