import { Router } from 'express';
import { query } from '../db.js';
import { requireAuth, requireAdmin, isAdminUser, meuAlunoId } from '../lib/acl.js';

const router = Router();
router.use(requireAuth);

router.get('/', async (req, res) => {
  const admin = isAdminUser(req.user);
  const { mes, ano } = req.query;

  if (admin) {
    let sql = 'SELECT * FROM mensalidades WHERE 1=1';
    const params = [];
    let i = 1;
    if (mes) { sql += ` AND mes = $${i++}`; params.push(parseInt(mes, 10)); }
    if (ano) { sql += ` AND ano = $${i++}`; params.push(parseInt(ano, 10)); }
    sql += ' ORDER BY aluno_nome';
    const r = await query(sql, params);
    return res.json(r.rows);
  }

  const alunoId = req.user?.aluno_id || (await meuAlunoId(req.userEmail));
  if (!alunoId) return res.json([]);
  const r = await query(
    'SELECT * FROM mensalidades WHERE aluno_id = $1 ORDER BY ano DESC, mes DESC',
    [alunoId],
  );
  res.json(r.rows);
});

router.get('/aluno/:alunoId', async (req, res) => {
  const admin = isAdminUser(req.user);
  const meuId = await meuAlunoId(req.userEmail);
  if (!admin && req.params.alunoId !== meuId) {
    return res.status(403).json({ error: 'Sem permissão.' });
  }
  const r = await query(
    'SELECT * FROM mensalidades WHERE aluno_id = $1 ORDER BY ano DESC, mes DESC',
    [req.params.alunoId],
  );
  res.json(r.rows);
});

router.get('/existe', async (req, res) => {
  const { aluno_id, mes, ano } = req.query;
  const r = await query(
    `SELECT id FROM mensalidades WHERE aluno_id = $1 AND mes = $2 AND ano = $3 AND cancelada = false LIMIT 1`,
    [aluno_id, parseInt(mes, 10), parseInt(ano, 10)],
  );
  res.json({ existe: r.rows.length > 0 });
});

router.post('/', requireAdmin, async (req, res) => {
  const body = req.body;
  const cols = Object.keys(body);
  const r = await query(
    `INSERT INTO mensalidades (${cols.join(', ')}) VALUES (${cols.map((_, i) => `$${i + 1}`).join(', ')}) RETURNING *`,
    cols.map((k) => body[k]),
  );
  res.status(201).json(r.rows[0]);
});

router.patch('/:id', requireAdmin, async (req, res) => {
  const body = { ...req.body, updated_at: new Date().toISOString() };
  delete body.id;
  const cols = Object.keys(body);
  const sets = cols.map((k, i) => `${k} = $${i + 1}`).join(', ');
  const r = await query(
    `UPDATE mensalidades SET ${sets} WHERE id = $${cols.length + 1} RETURNING *`,
    [...cols.map((k) => body[k]), req.params.id],
  );
  res.json(r.rows[0]);
});

router.post('/:id/pagar', requireAdmin, async (req, res) => {
  const hoje = new Date().toISOString().slice(0, 10);
  await query(
    `UPDATE mensalidades SET status = 'pago', data_pagamento = $1, mp_preferencia_id = NULL, updated_at = now() WHERE id = $2`,
    [hoje, req.params.id],
  );
  res.json({ ok: true });
});

router.patch('/:id/mp-preferencia', requireAdmin, async (req, res) => {
  await query(
    'UPDATE mensalidades SET mp_preferencia_id = $1, updated_at = now() WHERE id = $2',
    [req.body.mp_preferencia_id || null, req.params.id],
  );
  res.json({ ok: true });
});

router.get('/sync-mp/pendentes', requireAdmin, async (_req, res) => {
  const r = await query(
    `SELECT * FROM mensalidades WHERE status = 'pendente' AND cancelada = false AND mp_preferencia_id IS NOT NULL`,
  );
  res.json(r.rows);
});

router.delete('/:id', requireAdmin, async (req, res) => {
  await query('DELETE FROM mensalidades WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

router.post('/cancelar-futuras', requireAdmin, async (req, res) => {
  const { aluno_id, a_partir_mes, a_partir_ano, justificativa } = req.body;
  const r = await query(
    `SELECT * FROM mensalidades WHERE aluno_id = $1 AND status = 'pendente' AND ano >= $2`,
    [aluno_id, a_partir_ano],
  );
  for (const m of r.rows) {
    if (m.cancelada) continue;
    const depois = m.ano > a_partir_ano || (m.ano === a_partir_ano && m.mes >= a_partir_mes);
    if (!depois) continue;
    await query(
      `UPDATE mensalidades SET cancelada = true, observacao = $1, updated_at = now() WHERE id = $2`,
      [`Cancelada: ${justificativa}`, m.id],
    );
  }
  res.json({ ok: true });
});

export default router;
