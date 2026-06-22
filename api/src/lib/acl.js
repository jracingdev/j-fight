import { query } from '../db.js';

const ADMIN_EMAILS = new Set(['admin@jfight.app']);

export function roleForEmail(email) {
  const e = (email || '').trim().toLowerCase();
  return ADMIN_EMAILS.has(e) ? 'admin' : 'aluno';
}

export async function getUsuario(userId) {
  const r = await query('SELECT * FROM usuarios WHERE id = $1', [userId]);
  return r.rows[0] || null;
}

export function isAdminUser(u) {
  return u?.role === 'admin';
}

export async function meuAlunoId(email) {
  const r = await query(
    'SELECT id FROM alunos WHERE lower(trim(email)) = lower(trim($1)) LIMIT 1',
    [email],
  );
  return r.rows[0]?.id || null;
}

export async function idsColegasTurma(alunoId) {
  const r = await query(
    `SELECT DISTINCT at2.aluno_id
     FROM aluno_turmas at1
     JOIN aluno_turmas at2 ON at2.turma_id = at1.turma_id
     JOIN alunos a ON a.id = at2.aluno_id
     WHERE at1.aluno_id = $1
       AND at2.aluno_id <> $1
       AND a.cadastro_validado = true`,
    [alunoId],
  );
  return r.rows.map((row) => row.aluno_id);
}

export function requireAdmin(req, res, next) {
  if (!req.user || !isAdminUser(req.user)) {
    return res.status(403).json({ error: 'Acesso restrito a administradores.' });
  }
  next();
}

export function requireAuth(req, res, next) {
  if (!req.userId) {
    return res.status(401).json({ error: 'Não autenticado.' });
  }
  next();
}
