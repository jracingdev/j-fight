import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { config } from '../config.js';
import { requireAuth } from '../lib/acl.js';
import { authMiddleware } from '../middleware.js';

const router = Router();
router.use(authMiddleware);
const fotosDir = path.join(config.uploadDir, 'fotos');
fs.mkdirSync(fotosDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, fotosDir),
  filename: (req, file, cb) => {
    const pasta = req.body.pasta || 'geral';
    const ext = path.extname(file.originalname) || '.jpg';
    const name = `${pasta}/${Date.now()}${ext}`;
    const dir = path.join(fotosDir, pasta);
    fs.mkdirSync(dir, { recursive: true });
    cb(null, name);
  },
});

const upload = multer({ storage, limits: { fileSize: 8 * 1024 * 1024 } });

router.post('/fotos', requireAuth, upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Arquivo obrigatório.' });
  const url = `${config.publicUrl}/uploads/fotos/${req.file.filename.replace(/\\/g, '/')}`;
  res.json({ url });
});

export default router;
