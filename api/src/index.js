import express from 'express';
import cors from 'cors';
import path from 'path';
import fs from 'fs';
import bcrypt from 'bcryptjs';
import { randomUUID } from 'crypto';
import { config } from './config.js';
import { pool, query } from './db.js';
import { authMiddleware } from './middleware.js';
import authRoutes from './routes/auth.js';
import alunosRoutes from './routes/alunos.js';
import turmasRoutes from './routes/turmas.js';
import mensalidadesRoutes from './routes/mensalidades.js';
import presencasRoutes from './routes/presencas.js';
import lojaRoutes from './routes/loja.js';
import contentRoutes from './routes/content.js';
import financeiroRoutes from './routes/financeiro.js';
import backupRoutes from './routes/backup.js';
import filesRoutes from './routes/files.js';
import webhooksRoutes from './routes/webhooks.js';
import { roleForEmail } from './lib/acl.js';

const app = express();

const corsOrigins = (process.env.CORS_ORIGINS || 'https://jracingdev.github.io,http://localhost:*,http://127.0.0.1:*')
  .split(',')
  .map((o) => o.trim())
  .filter(Boolean);

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || corsOrigins.includes('*')) return callback(null, true);
      const allowed = corsOrigins.some((entry) => {
        if (entry.includes('*')) {
          const prefix = entry.replace(/\*+$/, '');
          return origin.startsWith(prefix);
        }
        return origin === entry;
      });
      callback(null, allowed);
    },
    credentials: true,
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }),
);
app.options('*', cors());
app.use(express.json({ limit: '10mb' }));

const uploadsPath = path.resolve(config.uploadDir);
fs.mkdirSync(uploadsPath, { recursive: true });
app.use('/uploads', express.static(uploadsPath));

app.get('/health', (_req, res) => res.json({ ok: true, app: 'jfight-api' }));

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/alunos', authMiddleware, alunosRoutes);
app.use('/api/v1/turmas', authMiddleware, turmasRoutes);
app.use('/api/v1/mensalidades', authMiddleware, mensalidadesRoutes);
app.use('/api/v1/presencas', authMiddleware, presencasRoutes);
app.use('/api/v1', lojaRoutes);
app.use('/api/v1', authMiddleware, contentRoutes);
app.use('/api/v1/financeiro', authMiddleware, financeiroRoutes);
app.use('/api/v1/backup', authMiddleware, backupRoutes);
app.use('/api/v1/files', filesRoutes);
app.use('/api/v1/webhooks/mercadopago', webhooksRoutes);

async function seedAdmin() {
  const email = config.adminEmail;
  const exists = await query('SELECT id FROM auth_accounts WHERE lower(email) = $1', [email]);
  if (exists.rows.length) return;

  const id = randomUUID();
  const hash = await bcrypt.hash(config.adminPassword, 12);
  await query(
    'INSERT INTO auth_accounts (id, email, password_hash, email_confirmed) VALUES ($1, $2, $3, true)',
    [id, email, hash],
  );
  await query(
    'INSERT INTO usuarios (id, nome, email, role) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING',
    [id, config.adminNome, email, roleForEmail(email)],
  );
  console.log(`Admin criado: ${email}`);
}

async function start() {
  try {
    await pool.query('SELECT 1');
    await seedAdmin();
  } catch (e) {
    console.error('Falha ao conectar PostgreSQL. Verifique DATABASE_URL e execute postgres/install.sql');
    console.error(e.message);
    process.exit(1);
  }

  app.listen(config.port, () => {
    console.log(`J FIGHT API em http://localhost:${config.port}`);
    console.log(`Base: ${config.publicUrl}/api/v1`);
  });
}

start();
