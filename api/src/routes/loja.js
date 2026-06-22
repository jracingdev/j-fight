import { Router } from 'express';
import { query } from '../db.js';
import { requireAuth, requireAdmin, isAdminUser, meuAlunoId } from '../lib/acl.js';
import { authMiddleware } from '../middleware.js';

const router = Router();

// Parse JWT em todas as rotas da loja (requireAuth depende de req.userId).
router.use(authMiddleware);

// ── Produtos ────────────────────────────────────────────────
router.get('/produtos', async (req, res) => {
  const admin = req.user && isAdminUser(req.user);
  const { ativo } = req.query;
  let sql = 'SELECT * FROM produtos';
  const params = [];
  if (ativo !== undefined) {
    sql += ' WHERE ativo = $1';
    params.push(ativo === 'true');
  } else if (!admin) {
    sql += ' WHERE ativo = true';
  }
  sql += ' ORDER BY nome';
  const r = await query(sql, params);
  res.json(r.rows);
});

router.post('/produtos', requireAuth, requireAdmin, async (req, res) => {
  const body = req.body;
  const cols = Object.keys(body);
  const r = await query(
    `INSERT INTO produtos (${cols.join(', ')}) VALUES (${cols.map((_, i) => `$${i + 1}`).join(', ')}) RETURNING *`,
    cols.map((k) => body[k]),
  );
  res.status(201).json(r.rows[0]);
});

router.patch('/produtos/:id', requireAuth, requireAdmin, async (req, res) => {
  const body = { ...req.body };
  delete body.id;
  const cols = Object.keys(body);
  const r = await query(
    `UPDATE produtos SET ${cols.map((k, i) => `${k} = $${i + 1}`).join(', ')} WHERE id = $${cols.length + 1} RETURNING *`,
    [...cols.map((k) => body[k]), req.params.id],
  );
  res.json(r.rows[0]);
});

router.delete('/produtos/:id', requireAuth, requireAdmin, async (req, res) => {
  await query('DELETE FROM produtos WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

// ── Variantes ───────────────────────────────────────────────
router.get('/produtos/:produtoId/variantes', async (req, res) => {
  const r = await query('SELECT * FROM produto_variantes WHERE produto_id = $1', [req.params.produtoId]);
  res.json(r.rows);
});

router.get('/variantes', async (req, res) => {
  const ids = (req.query.produto_ids || '').split(',').filter(Boolean);
  if (!ids.length) return res.json([]);
  const r = await query('SELECT * FROM produto_variantes WHERE produto_id = ANY($1)', [ids]);
  res.json(r.rows);
});

router.put('/produtos/:produtoId/variantes', requireAuth, requireAdmin, async (req, res) => {
  const variantes = req.body.variantes || [];
  await query('DELETE FROM produto_variantes WHERE produto_id = $1', [req.params.produtoId]);
  for (const v of variantes) {
    const cols = Object.keys(v).filter((k) => k !== 'id');
    await query(
      `INSERT INTO produto_variantes (produto_id, ${cols.join(', ')}) VALUES ($1, ${cols.map((_, i) => `$${i + 2}`).join(', ')})`,
      [req.params.produtoId, ...cols.map((k) => v[k])],
    );
  }
  res.json({ ok: true });
});

// ── Pedidos ─────────────────────────────────────────────────
const colsLista = `id, aluno_id, aluno_nome, aluno_email, aluno_telefone,
produto_id, produto_nome, variante_cor, variante_tamanho,
quantidade, valor_unitario, valor_total, status, forma_pagamento,
link_pagamento, pago, data_pagamento, codigo_rastreamento,
transportadora, link_rastreamento, data_envio, data_entrega_estimada,
observacoes, observacoes_admin, created_at`;

router.get('/pedidos', requireAuth, async (req, res) => {
  const admin = isAdminUser(req.user);
  const { status } = req.query;
  if (admin) {
    let sql = `SELECT ${colsLista} FROM pedidos WHERE 1=1`;
    const params = [];
    if (status) { sql += ' AND status = $1'; params.push(status); }
    sql += ' ORDER BY created_at DESC';
    const r = await query(sql, params);
    return res.json(r.rows);
  }
  const email = (req.userEmail || '').toLowerCase();
  const alunoId = req.user?.aluno_id || (await meuAlunoId(req.userEmail));
  const r = await query(
    `SELECT ${colsLista} FROM pedidos
     WHERE lower(aluno_email) = $1 OR aluno_id = $2
     ORDER BY created_at DESC`,
    [email, alunoId],
  );
  res.json(r.rows);
});

router.post('/pedidos', authMiddleware, async (req, res) => {
  const body = { ...req.body };
  if (body.aluno_email) body.aluno_email = body.aluno_email.trim().toLowerCase();
  const cols = Object.keys(body);
  const r = await query(
    `INSERT INTO pedidos (${cols.join(', ')}) VALUES (${cols.map((_, i) => `$${i + 1}`).join(', ')}) RETURNING *`,
    cols.map((k) => body[k]),
  );
  res.status(201).json(r.rows[0]);
});

router.patch('/pedidos/:id', requireAuth, requireAdmin, async (req, res) => {
  const body = { ...req.body, updated_at: new Date().toISOString() };
  delete body.id;
  const cols = Object.keys(body);
  const r = await query(
    `UPDATE pedidos SET ${cols.map((k, i) => `${k} = $${i + 1}`).join(', ')} WHERE id = $${cols.length + 1} RETURNING *`,
    [...cols.map((k) => body[k]), req.params.id],
  );
  res.json(r.rows[0]);
});

router.delete('/pedidos/:id', requireAuth, requireAdmin, async (req, res) => {
  await query('DELETE FROM pedidos WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

export default router;
