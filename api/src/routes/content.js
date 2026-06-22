import { Router } from 'express';
import { query } from '../db.js';
import { requireAuth, requireAdmin, isAdminUser } from '../lib/acl.js';

function crudRouter(table, { publicReadActive = false, activeField = 'ativo' } = {}) {
  const router = Router();

  router.get('/', async (req, res) => {
    const admin = req.user && isAdminUser(req.user);
    const { ativo } = req.query;
    let sql = `SELECT * FROM ${table}`;
    const params = [];
    if (ativo !== undefined) {
      sql += ` WHERE ${activeField} = $1`;
      params.push(ativo === 'true');
    } else if (publicReadActive && !admin) {
      sql += ` WHERE ${activeField} = true`;
    }
    sql += ' ORDER BY created_at DESC';
    const r = await query(sql, params);
    res.json(r.rows);
  });

  router.post('/', requireAuth, requireAdmin, async (req, res) => {
    const body = req.body;
    const cols = Object.keys(body);
    const r = await query(
      `INSERT INTO ${table} (${cols.join(', ')}) VALUES (${cols.map((_, i) => `$${i + 1}`).join(', ')}) RETURNING *`,
      cols.map((k) => body[k]),
    );
    res.status(201).json(r.rows[0]);
  });

  router.patch('/:id', requireAuth, requireAdmin, async (req, res) => {
    const body = { ...req.body };
    delete body.id;
    const cols = Object.keys(body);
    const r = await query(
      `UPDATE ${table} SET ${cols.map((k, i) => `${k} = $${i + 1}`).join(', ')} WHERE id = $${cols.length + 1} RETURNING *`,
      [...cols.map((k) => body[k]), req.params.id],
    );
    res.json(r.rows[0]);
  });

  router.delete('/:id', requireAuth, requireAdmin, async (req, res) => {
    await query(`DELETE FROM ${table} WHERE id = $1`, [req.params.id]);
    res.json({ ok: true });
  });

  return router;
}

const router = Router();
router.use('/avisos', crudRouter('avisos', { publicReadActive: true }));
router.use('/eventos', crudRouter('eventos'));
router.use('/medalhas', crudRouter('medalhas', { publicReadActive: true }));

router.post('/termos-aceites', requireAuth, async (req, res) => {
  const body = req.body;
  await query(
    `INSERT INTO termos_aceites (user_id, nome, email, tipo, ip, user_agent) VALUES ($1, $2, $3, $4, $5, $6)`,
    [body.user_id || req.userId, body.nome, body.email, body.tipo, body.ip, body.user_agent],
  );
  res.status(201).json({ ok: true });
});

export default router;
