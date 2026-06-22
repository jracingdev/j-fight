import { Router } from 'express';
import { query } from '../db.js';
import { requireAuth, requireAdmin } from '../lib/acl.js';

const router = Router();

router.get('/config', requireAuth, requireAdmin, async (_req, res) => {
  const r = await query('SELECT * FROM financeiro_config WHERE id = 1');
  res.json(r.rows[0] || {});
});

router.put('/config', requireAuth, requireAdmin, async (req, res) => {
  const body = req.body;
  const cols = Object.keys(body).filter((k) => k !== 'id');
  const r = await query(
    `INSERT INTO financeiro_config (id, ${cols.join(', ')})
     VALUES (1, ${cols.map((_, i) => `$${i + 1}`).join(', ')})
     ON CONFLICT (id) DO UPDATE SET ${cols.map((k, i) => `${k} = EXCLUDED.${k}`).join(', ')}
     RETURNING *`,
    cols.map((k) => body[k]),
  );
  res.json(r.rows[0]);
});

router.patch('/config/mp-token', requireAuth, requireAdmin, async (req, res) => {
  await query('UPDATE financeiro_config SET mp_access_token = $1 WHERE id = 1', [
    req.body.mp_access_token || null,
  ]);
  res.json({ ok: true });
});

export default router;
