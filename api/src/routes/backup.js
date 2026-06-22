import { Router } from 'express';
import { query } from '../db.js';
import { requireAuth, requireAdmin } from '../lib/acl.js';

const router = Router();
router.use(requireAuth, requireAdmin);

const TABLES = ['alunos', 'mensalidades', 'produtos', 'produto_variantes', 'avisos', 'eventos', 'turmas', 'aluno_turmas'];
const IMPORT_ORDER = ['avisos', 'eventos', 'produto_variantes', 'produtos', 'mensalidades', 'alunos'];

router.get('/export', async (_req, res) => {
  const data = {
    app: 'j_fight',
    version: 3,
    exported_at: new Date().toISOString(),
  };
  for (const table of TABLES) {
    const r = await query(`SELECT * FROM ${table}`);
    data[table] = r.rows;
  }
  res.json(data);
});

router.post('/import', async (req, res) => {
  const data = req.body;
  if (data.app !== 'j_fight') {
    return res.status(400).json({ error: 'Arquivo inválido.' });
  }
  for (const table of IMPORT_ORDER) {
    const rows = data[table] || [];
    if (!rows.length) continue;
    await query(`DELETE FROM ${table} WHERE id <> '00000000-0000-0000-0000-000000000000'`);
    for (const row of rows) {
      const cols = Object.keys(row);
      await query(
        `INSERT INTO ${table} (${cols.join(', ')}) VALUES (${cols.map((_, i) => `$${i + 1}`).join(', ')})
         ON CONFLICT (id) DO NOTHING`,
        cols.map((k) => row[k]),
      );
    }
  }
  res.json({ ok: true });
});

export default router;
