import { Router } from 'express';
import { query } from '../db.js';
import { requireAuth, requireAdmin, isAdminUser } from '../lib/acl.js';

const router = Router();
router.use(requireAuth);

router.get('/', async (req, res) => {
  const apenasAtivas = req.query.apenas_ativas !== 'false';
  let sql = 'SELECT * FROM turmas';
  if (apenasAtivas) sql += ' WHERE ativa = true';
  sql += ' ORDER BY horario, nome';
  const r = await query(sql);
  res.json(r.rows);
});

router.get('/contagem', async (req, res) => {
  const r = await query('SELECT turma_id, count(*)::int AS total FROM aluno_turmas GROUP BY turma_id');
  const map = {};
  for (const row of r.rows) map[row.turma_id] = row.total;
  res.json(map);
});

router.get('/:id', async (req, res) => {
  const r = await query('SELECT * FROM turmas WHERE id = $1', [req.params.id]);
  if (!r.rows[0]) return res.status(404).json({ error: 'Não encontrado.' });
  res.json(r.rows[0]);
});

router.patch('/:id', requireAdmin, async (req, res) => {
  const { nome, horario, dias_semana, tipo } = req.body;
  const r = await query(
    `UPDATE turmas SET nome = COALESCE($1, nome), horario = COALESCE($2, horario),
     dias_semana = COALESCE($3, dias_semana), tipo = COALESCE($4, tipo) WHERE id = $5 RETURNING *`,
    [nome, horario, dias_semana, tipo, req.params.id],
  );
  res.json(r.rows[0]);
});

router.get('/:id/alunos', async (req, res) => {
  const r = await query('SELECT aluno_id FROM aluno_turmas WHERE turma_id = $1', [req.params.id]);
  res.json(r.rows.map((x) => x.aluno_id));
});

router.get('/aluno/:alunoId', async (req, res) => {
  const r = await query(
    `SELECT t.* FROM aluno_turmas at JOIN turmas t ON t.id = at.turma_id
     WHERE at.aluno_id = $1 ORDER BY t.horario, t.nome`,
    [req.params.alunoId],
  );
  res.json(r.rows);
});

router.get('/mapa/alunos', requireAdmin, async (_req, res) => {
  const r = await query(
    `SELECT at.aluno_id, t.* FROM aluno_turmas at JOIN turmas t ON t.id = at.turma_id`,
  );
  const map = {};
  for (const row of r.rows) {
    const { aluno_id, ...turma } = row;
    if (!map[aluno_id]) map[aluno_id] = [];
    map[aluno_id].push(turma);
  }
  res.json(map);
});

router.get('/mapa/turma-alunos', requireAdmin, async (_req, res) => {
  const r = await query('SELECT aluno_id, turma_id FROM aluno_turmas');
  const map = {};
  for (const row of r.rows) {
    if (!map[row.turma_id]) map[row.turma_id] = [];
    map[row.turma_id].push(row.aluno_id);
  }
  res.json(map);
});

router.put('/aluno/:alunoId', requireAdmin, async (req, res) => {
  const alunoId = req.params.alunoId;
  const turmaIds = req.body.turma_ids || [];
  const atuais = await query('SELECT turma_id FROM aluno_turmas WHERE aluno_id = $1', [alunoId]);
  const idsAtuais = new Set(atuais.rows.map((r) => r.turma_id));
  const novos = turmaIds.filter((id) => !idsAtuais.has(id));
  const removidos = [...idsAtuais].filter((id) => !turmaIds.includes(id));
  const hoje = new Date().toISOString().slice(0, 10);

  for (const tid of novos) {
    await query(
      'INSERT INTO aluno_turmas (aluno_id, turma_id, data_inicio) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING',
      [alunoId, tid, hoje],
    );
  }
  if (removidos.length) {
    await query('DELETE FROM aluno_turmas WHERE aluno_id = $1 AND turma_id = ANY($2)', [alunoId, removidos]);
  }
  res.json({ ok: true });
});

export default router;
