import { Router } from 'express';
import { query } from '../db.js';
import {
  requireAuth,
  requireAdmin,
  isAdminUser,
  meuAlunoId,
  idsColegasTurma,
} from '../lib/acl.js';

const router = Router();

router.use(requireAuth);

router.get('/', async (req, res) => {
  try {
    const admin = isAdminUser(req.user);
    const { ativo } = req.query;

    if (admin) {
      let sql = 'SELECT * FROM alunos';
      const params = [];
      if (ativo !== undefined) {
        sql += ' WHERE ativo = $1';
        params.push(ativo === 'true');
      }
      sql += ' ORDER BY nome';
      const r = await query(sql, params);
      return res.json(r.rows);
    }

    const alunoId = await meuAlunoId(req.userEmail);
    if (!alunoId) return res.json([]);

    const colegas = await idsColegasTurma(alunoId);
    const ids = [alunoId, ...colegas];
    const r = await query('SELECT * FROM alunos WHERE id = ANY($1) ORDER BY nome', [ids]);
    res.json(r.rows);
  } catch (e) {
    console.error('GET /alunos', e);
    res.status(500).json({ error: 'Erro ao listar alunos.' });
  }
});

router.get('/pendentes', requireAdmin, async (_req, res) => {
  const r = await query(
    'SELECT * FROM alunos WHERE cadastro_validado = false ORDER BY created_at DESC',
  );
  res.json(r.rows);
});

router.get('/colegas', async (req, res) => {
  const alunoId = req.user?.aluno_id || (await meuAlunoId(req.userEmail));
  if (!alunoId) return res.json([]);
  const colegas = await idsColegasTurma(alunoId);
  if (!colegas.length) return res.json([]);
  const r = await query('SELECT * FROM alunos WHERE id = ANY($1) ORDER BY nome', [colegas]);
  res.json(r.rows);
});

router.get('/email/:email', async (req, res) => {
  const email = decodeURIComponent(req.params.email);
  const admin = isAdminUser(req.user);
  const r = await query('SELECT * FROM alunos WHERE lower(email) = lower($1) LIMIT 1', [email]);
  const row = r.rows[0];
  if (!row) {
    if (admin) return res.status(204).end();
    return res.status(404).json({ error: 'Não encontrado.' });
  }
  const meuId = await meuAlunoId(req.userEmail);
  if (!admin && row.id !== meuId && !(await idsColegasTurma(meuId || '')).includes(row.id)) {
    return res.status(403).json({ error: 'Sem permissão.' });
  }
  res.json(row);
});

router.get('/:id', async (req, res) => {
  const r = await query('SELECT * FROM alunos WHERE id = $1', [req.params.id]);
  const row = r.rows[0];
  if (!row) return res.status(404).json({ error: 'Não encontrado.' });

  const admin = isAdminUser(req.user);
  const meuId = await meuAlunoId(req.userEmail);
  if (!admin && row.id !== meuId && !(meuId && (await idsColegasTurma(meuId)).includes(row.id))) {
    return res.status(403).json({ error: 'Sem permissão.' });
  }
  res.json(row);
});

router.post('/', async (req, res) => {
  const admin = isAdminUser(req.user);
  const body = { ...req.body };
  if (!admin) {
    body.email = req.userEmail;
  }
  const cols = Object.keys(body).filter((k) => body[k] !== undefined);
  const vals = cols.map((k) => body[k]);
  const ph = cols.map((_, i) => `$${i + 1}`).join(', ');
  const r = await query(
    `INSERT INTO alunos (${cols.join(', ')}) VALUES (${ph}) RETURNING *`,
    vals,
  );
  res.status(201).json(r.rows[0]);
});

router.patch('/:id', async (req, res) => {
  const existing = await query('SELECT * FROM alunos WHERE id = $1', [req.params.id]);
  const row = existing.rows[0];
  if (!row) return res.status(404).json({ error: 'Não encontrado.' });

  const admin = isAdminUser(req.user);
  const meuId = await meuAlunoId(req.userEmail);
  if (!admin && row.id !== meuId) {
    return res.status(403).json({ error: 'Sem permissão.' });
  }

  const body = { ...req.body, updated_at: new Date().toISOString() };
  if (!admin) delete body.email;
  delete body.id;
  const cols = Object.keys(body).filter((k) => body[k] !== undefined);
  const sets = cols.map((k, i) => `${k} = $${i + 1}`).join(', ');
  const vals = [...cols.map((k) => body[k]), req.params.id];
  const r = await query(`UPDATE alunos SET ${sets} WHERE id = $${cols.length + 1} RETURNING *`, vals);
  res.json(r.rows[0]);
});

router.delete('/:id', requireAdmin, async (req, res) => {
  await query('DELETE FROM alunos WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

router.post('/:id/validar', requireAdmin, async (req, res) => {
  await query(
    `UPDATE alunos SET cadastro_validado = true, ativo = true, updated_at = now() WHERE id = $1`,
    [req.params.id],
  );
  res.json({ ok: true });
});

router.post('/:id/validar-turmas', requireAdmin, async (req, res) => {
  const turmaIds = req.body.turma_ids || [];
  if (!turmaIds.length) return res.status(400).json({ error: 'Selecione pelo menos uma turma.' });
  await query(
    `UPDATE alunos SET cadastro_validado = true, ativo = true, updated_at = now() WHERE id = $1`,
    [req.params.id],
  );
  const hoje = new Date().toISOString().slice(0, 10);
  for (const tid of turmaIds) {
    await query(
      `INSERT INTO aluno_turmas (aluno_id, turma_id, data_inicio)
       VALUES ($1, $2, $3) ON CONFLICT DO NOTHING`,
      [req.params.id, tid, hoje],
    );
  }
  res.json({ ok: true });
});

export default router;
