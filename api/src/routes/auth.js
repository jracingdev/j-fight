import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { OAuth2Client } from 'google-auth-library';
import { randomUUID } from 'crypto';
import { query } from '../db.js';
import { config } from '../config.js';
import { signToken, authMiddleware } from '../middleware.js';
import { getUsuario, roleForEmail } from '../lib/acl.js';
import { requireAuth } from '../lib/acl.js';

const router = Router();
const googleClient = config.googleClientId
  ? new OAuth2Client(config.googleClientId)
  : null;

async function ensurePerfil(accountId, { email, nome, fotoUrl }) {
  let perfil = await getUsuario(accountId);
  if (perfil) {
    if (perfil.role === 'admin' && roleForEmail(email) !== 'admin') {
      await query('UPDATE usuarios SET role = $1 WHERE id = $2', ['aluno', accountId]);
      perfil = await getUsuario(accountId);
    }
    return perfil;
  }

  const role = roleForEmail(email);
  await query(
    `INSERT INTO usuarios (id, nome, email, role, foto_url)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, nome = COALESCE(usuarios.nome, EXCLUDED.nome)`,
    [accountId, nome, email, role, fotoUrl || null],
  );
  return getUsuario(accountId);
}

function authResponse(accountId, email, usuario) {
  const token = signToken({ sub: accountId, email });
  return { access_token: token, usuario };
}

router.post('/login', async (req, res) => {
  try {
    const email = (req.body.email || '').trim().toLowerCase();
    const password = req.body.password || '';
    if (!email || !password) {
      return res.status(400).json({ error: 'E-mail e senha são obrigatórios.' });
    }

    const acc = await query(
      'SELECT id, email, password_hash FROM auth_accounts WHERE lower(email) = $1',
      [email],
    );
    if (!acc.rows[0]?.password_hash) {
      return res.status(401).json({ error: 'Email ou senha incorretos.' });
    }

    const ok = await bcrypt.compare(password, acc.rows[0].password_hash);
    if (!ok) return res.status(401).json({ error: 'Email ou senha incorretos.' });

    const usuario = await ensurePerfil(acc.rows[0].id, {
      email: acc.rows[0].email,
      nome: email.split('@')[0],
    });
    return res.json(authResponse(acc.rows[0].id, acc.rows[0].email, usuario));
  } catch (e) {
    console.error('POST /auth/login', e);
    return res.status(500).json({ error: 'Erro ao entrar.' });
  }
});

router.post('/register', async (req, res) => {
  try {
    const nome = (req.body.nome || '').trim();
    const email = (req.body.email || '').trim().toLowerCase();
    const password = req.body.password || '';
    if (!nome || !email || !password) {
      return res.status(400).json({ error: 'Preencha nome, e-mail e senha.' });
    }
    if (password.length < 6) {
      return res.status(400).json({ error: 'Senha deve ter pelo menos 6 caracteres.' });
    }

    const exists = await query('SELECT id FROM auth_accounts WHERE lower(email) = $1', [email]);
    if (exists.rows.length) {
      return res.status(409).json({ error: 'Este e-mail já está cadastrado.' });
    }

    const id = randomUUID();
    const hash = await bcrypt.hash(password, 12);
    await query(
      'INSERT INTO auth_accounts (id, email, password_hash, email_confirmed) VALUES ($1, $2, $3, true)',
      [id, email, hash],
    );
    const usuario = await ensurePerfil(id, { email, nome });
    return res.status(201).json(authResponse(id, email, usuario));
  } catch (e) {
    console.error('POST /auth/register', e);
    return res.status(500).json({ error: 'Erro ao criar conta.' });
  }
});

router.post('/google', async (req, res) => {
  try {
    const idToken = req.body.id_token;
    if (!idToken) return res.status(400).json({ error: 'id_token obrigatório.' });
    if (!googleClient) {
      return res.status(503).json({ error: 'Google OAuth não configurado no servidor.' });
    }

    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: config.googleClientId,
    });
    const payload = ticket.getPayload();
    const email = (payload.email || '').toLowerCase();
    if (!email) return res.status(400).json({ error: 'Google não retornou e-mail.' });

    let acc = await query('SELECT id, email FROM auth_accounts WHERE lower(email) = $1', [email]);
    let accountId;
    if (acc.rows[0]) {
      accountId = acc.rows[0].id;
    } else {
      accountId = randomUUID();
      await query(
        'INSERT INTO auth_accounts (id, email, password_hash, email_confirmed) VALUES ($1, $2, NULL, true)',
        [accountId, email],
      );
    }

    const nome = payload.name || email.split('@')[0];
    const usuario = await ensurePerfil(accountId, {
      email,
      nome,
      fotoUrl: payload.picture,
    });
    return res.json(authResponse(accountId, email, usuario));
  } catch (e) {
    console.error('POST /auth/google', e);
    return res.status(401).json({ error: 'Não foi possível validar login Google.' });
  }
});

router.get('/me', authMiddleware, requireAuth, async (req, res) => {
  const usuario = await getUsuario(req.userId);
  if (!usuario) return res.status(404).json({ error: 'Perfil não encontrado.' });
  res.json({ usuario });
});

router.patch('/me', authMiddleware, requireAuth, async (req, res) => {
  try {
    const { nome, email } = req.body;
    const updates = [];
    const params = [];
    let i = 1;
    if (nome) {
      updates.push(`nome = $${i++}`);
      params.push(nome);
    }
    if (email) {
      updates.push(`email = $${i++}`);
      params.push(email.trim());
      await query('UPDATE auth_accounts SET email = $1 WHERE id = $2', [email.trim().toLowerCase(), req.userId]);
    }
    if (updates.length) {
      params.push(req.userId);
      await query(`UPDATE usuarios SET ${updates.join(', ')} WHERE id = $${i}`, params);
    }
    const usuario = await getUsuario(req.userId);
    res.json({ usuario });
  } catch (e) {
    console.error('PATCH /auth/me', e);
    res.status(500).json({ error: 'Erro ao atualizar perfil.' });
  }
});

router.patch('/me/password', authMiddleware, requireAuth, async (req, res) => {
  try {
    const password = req.body.password || '';
    if (password.length < 6) {
      return res.status(400).json({ error: 'Senha deve ter pelo menos 6 caracteres.' });
    }
    const hash = await bcrypt.hash(password, 12);
    await query('UPDATE auth_accounts SET password_hash = $1 WHERE id = $2', [hash, req.userId]);
    res.json({ ok: true });
  } catch (e) {
    console.error('PATCH /auth/me/password', e);
    res.status(500).json({ error: 'Erro ao alterar senha.' });
  }
});

router.post('/forgot-password', async (req, res) => {
  // Stub: em produção, enviar e-mail com token de reset
  res.json({
    ok: true,
    message: 'Se o e-mail existir, você receberá instruções. (Configure SMTP no servidor para ativar.)',
  });
});

router.post('/logout', (_req, res) => {
  res.json({ ok: true });
});

router.patch('/users/:id/aluno', authMiddleware, requireAuth, async (req, res) => {
  if (req.userId !== req.params.id && req.user?.role !== 'admin') {
    return res.status(403).json({ error: 'Sem permissão.' });
  }
  await query('UPDATE usuarios SET aluno_id = $1 WHERE id = $2', [req.body.aluno_id, req.params.id]);
  res.json({ ok: true });
});

export default router;
