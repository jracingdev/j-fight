import { Router } from 'express';
import { randomUUID } from 'crypto';
import { query } from '../db.js';
import { requireAuth, requireAdmin, isAdminUser, meuAlunoId } from '../lib/acl.js';

const router = Router();
router.use(requireAuth);

router.get('/', async (req, res) => {
  const admin = isAdminUser(req.user);
  const { turma_id, data_aula } = req.query;

  if (turma_id && data_aula) {
    if (!admin) return res.status(403).json({ error: 'Sem permissão.' });
    const r = await query(
      'SELECT * FROM presencas WHERE turma_id = $1 AND data_aula = $2',
      [turma_id, data_aula],
    );
    return res.json(r.rows);
  }

  const limite = parseInt(req.query.limite || '30', 10);
  const alunoId = req.user?.aluno_id || (await meuAlunoId(req.userEmail));
  if (!alunoId) return res.json([]);
  const r = await query(
    'SELECT * FROM presencas WHERE aluno_id = $1 ORDER BY data_aula DESC LIMIT $2',
    [alunoId, limite],
  );
  res.json(r.rows);
});

router.get('/contagem-mes', async (req, res) => {
  const { mes, ano } = req.query;
  const prefix = `${ano}-${String(mes).padStart(2, '0')}`;
  const alunoId = req.user?.aluno_id || (await meuAlunoId(req.userEmail));
  if (!alunoId) return res.json({ total: 0 });
  const r = await query(
    `SELECT count(*)::int AS total FROM presencas
     WHERE aluno_id = $1 AND presente = true AND data_aula LIKE $2`,
    [alunoId, `${prefix}%`],
  );
  res.json({ total: r.rows[0]?.total || 0 });
});

router.put('/chamada', requireAdmin, async (req, res) => {
  const { turma_id, data_aula, por_aluno } = req.body;
  for (const [alunoId, info] of Object.entries(por_aluno || {})) {
    await query(
      `INSERT INTO presencas (turma_id, aluno_id, aluno_nome, data_aula, presente, origem)
       VALUES ($1, $2, $3, $4, $5, 'chamada')
       ON CONFLICT (turma_id, aluno_id, data_aula)
       DO UPDATE SET presente = EXCLUDED.presente, aluno_nome = EXCLUDED.aluno_nome`,
      [turma_id, alunoId, info.nome, data_aula, info.presente],
    );
  }
  res.json({ ok: true });
});

router.delete('/:id', requireAdmin, async (req, res) => {
  await query('DELETE FROM presencas WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

// Config
router.get('/config', async (_req, res) => {
  const r = await query('SELECT * FROM presenca_config WHERE id = 1');
  res.json(r.rows[0] || { id: 1, metodo: 'chamada', token_validade_minutos: 30 });
});

router.put('/config', requireAdmin, async (req, res) => {
  const { metodo, token_validade_minutos } = req.body;
  const r = await query(
    `INSERT INTO presenca_config (id, metodo, token_validade_minutos, updated_at)
     VALUES (1, $1, $2, now())
     ON CONFLICT (id) DO UPDATE SET metodo = EXCLUDED.metodo,
       token_validade_minutos = EXCLUDED.token_validade_minutos, updated_at = now()
     RETURNING *`,
    [metodo, token_validade_minutos],
  );
  res.json(r.rows[0]);
});

// QR tokens
router.post('/tokens', requireAdmin, async (req, res) => {
  const { tipo, turma_id } = req.body;
  if (!['turma', 'unico'].includes(tipo)) {
    return res.status(400).json({ error: 'Tipo inválido.' });
  }
  if (tipo === 'turma' && !turma_id) {
    return res.status(400).json({ error: 'Informe a turma.' });
  }

  const cfg = await query('SELECT token_validade_minutos FROM presenca_config WHERE id = 1');
  const mins = cfg.rows[0]?.token_validade_minutos || 30;
  const dataAula = new Date().toISOString().slice(0, 10);
  const token = randomUUID().replace(/-/g, '') + randomUUID().replace(/-/g, '');

  await query(
    `UPDATE presenca_tokens SET ativo = false WHERE ativo = true AND tipo = $1
     AND (($2 = 'turma' AND turma_id = $3) OR $2 = 'unico')`,
    [tipo, tipo, turma_id || null],
  );

  const validoAte = new Date(Date.now() + mins * 60 * 1000).toISOString();
  await query(
    `INSERT INTO presenca_tokens (token, tipo, turma_id, data_aula, valido_ate) VALUES ($1, $2, $3, $4, $5)`,
    [token, tipo, turma_id || null, dataAula, validoAte],
  );

  res.json({ token, tipo, turma_id: turma_id || null, data_aula: dataAula, valido_ate: validoAte });
});

router.post('/checkin', async (req, res) => {
  const pToken = req.body.token;
  const alunoId = req.user?.aluno_id || (await meuAlunoId(req.userEmail));
  if (!alunoId) return res.status(400).json({ error: 'Cadastro de aluno não encontrado.' });

  const aluno = await query('SELECT nome, cadastro_validado FROM alunos WHERE id = $1', [alunoId]);
  if (!aluno.rows[0]?.cadastro_validado) {
    return res.status(403).json({ error: 'Seu cadastro ainda não foi validado pelo professor.' });
  }

  const tok = await query(
    `SELECT * FROM presenca_tokens WHERE token = $1 AND ativo = true AND valido_ate > now() LIMIT 1`,
    [pToken],
  );
  if (!tok.rows[0]) {
    return res.status(400).json({ error: 'QR inválido ou expirado. Peça ao professor para gerar um novo.' });
  }

  const t = tok.rows[0];
  let turmaId = t.turma_id;

  if (t.tipo === 'turma') {
    const mat = await query(
      'SELECT 1 FROM aluno_turmas WHERE aluno_id = $1 AND turma_id = $2',
      [alunoId, turmaId],
    );
    if (!mat.rows.length) {
      return res.status(403).json({ error: 'Você não está matriculado nesta turma.' });
    }
  } else {
    turmaId = await turmaCheckinAluno(alunoId, t.data_aula);
    if (!turmaId) {
      return res.status(400).json({ error: 'Você não está em nenhuma turma ativa.' });
    }
  }

  const turma = await query('SELECT nome FROM turmas WHERE id = $1', [turmaId]);
  const nome = aluno.rows[0].nome;

  await query(
    `INSERT INTO presencas (turma_id, aluno_id, aluno_nome, data_aula, presente, origem)
     VALUES ($1, $2, $3, $4, true, 'qr')
     ON CONFLICT (turma_id, aluno_id, data_aula)
     DO UPDATE SET presente = true, origem = 'qr', aluno_nome = EXCLUDED.aluno_nome`,
    [turmaId, alunoId, nome, t.data_aula],
  );

  res.json({
    ok: true,
    turma_nome: turma.rows[0]?.nome,
    data_aula: t.data_aula,
    aluno_nome: nome,
  });
});

async function turmaCheckinAluno(alunoId, dataAula) {
  const dow = new Date(dataAula).getDay();
  let r = await query(
    `SELECT at.turma_id FROM aluno_turmas at
     JOIN turmas t ON t.id = at.turma_id AND t.ativa = true
     WHERE at.aluno_id = $1
       AND (t.dias_semana IS NULL OR cardinality(t.dias_semana) = 0 OR $2::text = ANY(t.dias_semana))
     ORDER BY t.nome LIMIT 1`,
    [alunoId, String(dow)],
  );
  if (r.rows[0]) return r.rows[0].turma_id;
  r = await query(
    `SELECT at.turma_id FROM aluno_turmas at
     JOIN turmas t ON t.id = at.turma_id AND t.ativa = true
     WHERE at.aluno_id = $1 ORDER BY t.nome LIMIT 1`,
    [alunoId],
  );
  return r.rows[0]?.turma_id || null;
}

export default router;
