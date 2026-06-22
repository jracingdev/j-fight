-- ============================================================
-- J FIGHT — Catálogo da loja (substitui TODOS os produtos)
-- Execute no SQL Editor do Supabase (role postgres)
-- Fotos: URLs Unsplash/Pexels (também em web/loja/ para GitHub Pages)
-- ============================================================

begin;

delete from public.pedidos;
delete from public.produto_variantes;
delete from public.produtos;

with cfg as (
  select * from (values
    ('Kimono Competição IBJJF Trançado', 'https://images.unsplash.com/photo-1576149146095-caa19d4de102?w=800&q=85'),
    ('Kimono Kids Ultra Leve', 'https://images.pexels.com/photos/4754142/pexels-photo-4754142.jpeg?auto=compress&cs=tinysrgb&w=800'),
    ('Rashguard Manga Longa UV50+', 'https://images.unsplash.com/photo-1542937306-0a804f0ad7b7?w=800&q=85'),
    ('Rashguard Sublimada No-Gi', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=85'),
    ('Shorts No-Gi Pro Flex', 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&q=85'),
    ('Faixa Oficial CBJJ Trançada', 'https://images.unsplash.com/photo-1720730978839-844e7214e1ca?w=800&q=85'),
    ('Protetor Bucal Duplo (adulto)', 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=800&q=85'),
    ('Bandagem Adesiva para Dedos 10m', 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=800&q=85'),
    ('Mochila Academia 40L', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&q=85'),
    ('Camiseta Dry Fit Treino', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&q=85'),
    ('Kit Iniciante Kimono + Faixa Branca', 'https://images.unsplash.com/photo-1742863067822-7719483acb63?w=800&q=85'),
    ('Boné Aba Curva J FIGHT', 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=800&q=85'),
    ('Shaker 600ml Antivazamento', 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800&q=85'),
    ('Luvas MMA Treino 12oz', 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&q=85')
  ) as t(nome, foto)
),
novos as (
  insert into public.produtos (
    nome, categoria, descricao, preco, foto_url, prazo_entrega, prazo_dias, ativo
  )
  select
    v.nome, v.categoria, v.descricao, v.preco, c.foto,
    v.prazo_entrega, v.prazo_dias, v.ativo
  from (values
    (
      'Kimono Competição IBJJF Trançado'::text, 'kimono'::text,
      'Tecido trançado 450gsm, corte slim competitivo, reforço duplo nos joelhos. Ideal para IBJJF e treinos intensos.'::text,
      429.90::numeric, 'dias'::text, 10, true
    ),
    (
      'Kimono Kids Ultra Leve',
      'kimono',
      'Modelo infantil 280gsm, macio e resistente. Cores vibrantes, ideal para Baby e Kids.',
      279.90, 'dias', 12, true
    ),
    (
      'Rashguard Manga Longa UV50+',
      'camisa',
      'Compressão média, proteção solar UV50+, costura reforçada. Perfeita para no-gi e treino outdoor.',
      159.90, 'dias', 7, true
    ),
    (
      'Rashguard Sublimada No-Gi',
      'camisa',
      'Estampa sublimada que não desbota, tecido respirável e secagem rápida. Modelagem atlética.',
      149.90, 'dias', 7, true
    ),
    (
      'Shorts No-Gi Pro Flex',
      'short',
      'Elástico 4 vias, cordão interno, bolsos discretos. Liberdade total para guarda e passagem.',
      129.90, 'imediato', 0, true
    ),
    (
      'Faixa Oficial CBJJ Trançada',
      'faixa',
      'Faixa oficial trançada, etiqueta de graduação inclusa. Disponível em todas as cores adulto e infantil.',
      64.90, 'imediato', 0, true
    ),
    (
      'Protetor Bucal Duplo (adulto)',
      'outro',
      'Camada dupla, moldável em água quente, proteção superior e inferior. Obrigatório em sparrings.',
      49.90, 'imediato', 0, true
    ),
    (
      'Bandagem Adesiva para Dedos 10m',
      'outro',
      'Rolo 10 metros, alta aderência, protege articulações em grips intensos. Essencial no tatame.',
      32.90, 'imediato', 0, true
    ),
    (
      'Mochila Academia 40L',
      'outro',
      'Compartimento ventilado para kimono, bolso para chinelo e garrafa. Alças acolchoadas.',
      199.90, 'dias', 14, true
    ),
    (
      'Camiseta Dry Fit Treino',
      'camisa',
      'Tecido dry fit antibacteriano, logo J FIGHT bordado. Conforto para musculação e aquecimento.',
      89.90, 'imediato', 0, true
    ),
    (
      'Kit Iniciante Kimono + Faixa Branca',
      'outro',
      'Kimono entrada + faixa branca oficial + patch da academia. Melhor custo-benefício para novos alunos.',
      349.90, 'dias', 10, true
    ),
    (
      'Boné Aba Curva J FIGHT',
      'outro',
      'Aba curva, ajuste snapback, bordado premium. Represente a equipe dentro e fora da academia.',
      59.90, 'imediato', 0, true
    ),
    (
      'Shaker 600ml Antivazamento',
      'outro',
      'Tampa com trava, escala interna, livre de BPA. Para whey, BCAA ou hidratação pós-treino.',
      45.90, 'imediato', 0, true
    ),
    (
      'Luvas MMA Treino 12oz',
      'outro',
      'Palmilha em gel, velcro reforçado, indicada para striking e MMA fitness. Par.',
      179.90, 'dias', 8, true
    )
  ) as v(nome, categoria, descricao, preco, prazo_entrega, prazo_dias, ativo)
  join cfg c on c.nome = v.nome
  returning id, nome
)
insert into public.produto_variantes (produto_id, cor, tamanho, estoque)
select p.id, v.cor, v.tam, v.est
from novos p
join lateral (values
  ('Branco','A1',3),('Branco','A2',8),('Branco','A3',7),('Branco','A4',5),
  ('Azul','A2',4),('Azul','A3',6),('Preto','A2',3),('Preto','A3',4)
) as v(cor, tam, est) on p.nome = 'Kimono Competição IBJJF Trançado'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values
  ('Branco','M0',4),('Branco','M1',6),('Branco','M2',5),('Branco','M3',3),('Azul','M1',4),('Azul','M2',3)
) as v(cor, tam, est) on p.nome = 'Kimono Kids Ultra Leve'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values
  ('Preto','P',12),('Preto','M',15),('Preto','G',10),('Preto','GG',6),('Vermelho','M',8),('Vermelho','G',7),('Azul Marinho','G',5)
) as v(cor, tam, est) on p.nome = 'Rashguard Manga Longa UV50+'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values
  ('Preto','P',10),('Preto','M',14),('Cinza','G',8),('Branco','M',6)
) as v(cor, tam, est) on p.nome = 'Rashguard Sublimada No-Gi'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values
  ('Preto','P',8),('Preto','M',12),('Azul','G',6),('Verde','M',4)
) as v(cor, tam, est) on p.nome = 'Shorts No-Gi Pro Flex'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values
  ('Branca','A1',15),('Branca','A2',12),('Azul','A2',10),('Azul','A3',8),('Roxa','A3',6),('Marrom','A4',4),('Preta','A4',5)
) as v(cor, tam, est) on p.nome = 'Faixa Oficial CBJJ Trançada'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values
  ('Transparente','Único',25),('Azul','Único',18),('Preto','Único',20)
) as v(cor, tam, est) on p.nome = 'Protetor Bucal Duplo (adulto)'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values ('Bege','10m',40)) as v(cor, tam, est) on p.nome = 'Bandagem Adesiva para Dedos 10m'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values ('Preto','40L',6),('Cinza','40L',4)) as v(cor, tam, est) on p.nome = 'Mochila Academia 40L'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values
  ('Preto','P',14),('Preto','M',18),('Preto','G',12),('Branco','M',10),('Vermelho','G',8)
) as v(cor, tam, est) on p.nome = 'Camiseta Dry Fit Treino'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values ('Branco','A1',5),('Branco','A2',8),('Branco','A3',4)) as v(cor, tam, est) on p.nome = 'Kit Iniciante Kimono + Faixa Branca'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values ('Preto','Único',20),('Vermelho','Único',15)) as v(cor, tam, est) on p.nome = 'Boné Aba Curva J FIGHT'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values ('Preto','600ml',30),('Transparente','600ml',25)) as v(cor, tam, est) on p.nome = 'Shaker 600ml Antivazamento'
union all select p.id, v.cor, v.tam, v.est from novos p
join lateral (values
  ('Preto/Vermelho','12oz',8),('Azul/Branco','14oz',5),('Preto','16oz',4)
) as v(cor, tam, est) on p.nome = 'Luvas MMA Treino 12oz';

-- Pedidos demo (se existirem alunos demo)
insert into public.pedidos (
  aluno_id, aluno_nome, aluno_email, aluno_telefone,
  produto_id, produto_nome, variante_cor, variante_tamanho,
  quantidade, valor_unitario, valor_total, status, forma_pagamento,
  pago, data_pagamento, observacoes, observacoes_admin
)
select
  a.id, a.nome, a.email, a.telefone,
  p.id, p.nome, 'Branco', 'A2', 1, p.preco, p.preco,
  v.st, v.fp, v.pago, v.dp, v.obs, 'loja_demo'
from public.alunos a
cross join lateral (values
  ('entregue'::text,   'pix'::text,       true,  to_char(current_date - 12, 'YYYY-MM-DD'), 'Retirado na recepção'),
  ('enviado',          'mercadopago',     true,  to_char(current_date - 4,  'YYYY-MM-DD'), 'Rastreio enviado'),
  ('preparando',       'whatsapp',        false, null::text, 'Separando estoque'),
  ('confirmado',       'pix',             true,  to_char(current_date - 1,  'YYYY-MM-DD'), null),
  ('pendente',         'whatsapp',        false, null, 'Aguardando pagamento')
) as v(st, fp, pago, dp, obs)
join public.produtos p on p.nome = 'Kimono Competição IBJJF Trançado'
where a.email in (
  'demo.marcos.silva@jfight.app','demo.fernanda.costa@jfight.app','demo.larissa.rocha@jfight.app'
)
limit 12;

insert into public.pedidos (
  aluno_id, aluno_nome, aluno_email, aluno_telefone,
  produto_id, produto_nome, variante_cor, variante_tamanho,
  quantidade, valor_unitario, valor_total, status, forma_pagamento,
  pago, observacoes, observacoes_admin
)
select
  null, 'Visitante Loja', 'visitante@demo.jfight.app', '21990019999',
  p.id, p.nome, 'Preto', 'M', 1, p.preco, p.preco,
  'pendente', 'whatsapp', false, 'Compra sem login — demonstração', 'loja_demo'
from public.produtos p
where p.nome = 'Rashguard Sublimada No-Gi'
limit 1;

commit;

select
  (select count(*) from public.produtos) as produtos,
  (select count(*) from public.produto_variantes) as variantes,
  (select count(*) from public.pedidos) as pedidos,
  'Catálogo atualizado com 14 produtos e fotos reais.' as status;
