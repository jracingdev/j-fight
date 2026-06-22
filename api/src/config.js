import 'dotenv/config';

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  databaseUrl: process.env.DATABASE_URL || 'postgresql://jfight:senha@localhost:5432/jfight',
  jwtSecret: process.env.JWT_SECRET || 'dev-only-change-in-production',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '30d',
  publicUrl: (process.env.PUBLIC_URL || `http://localhost:${process.env.PORT || 3000}`).replace(/\/$/, ''),
  uploadDir: process.env.UPLOAD_DIR || './uploads',
  googleClientId: process.env.GOOGLE_CLIENT_ID || '',
  adminEmail: (process.env.ADMIN_EMAIL || 'admin@jfight.app').toLowerCase(),
  adminPassword: process.env.ADMIN_PASSWORD || 'Demo@2026',
  adminNome: process.env.ADMIN_NOME || 'Administrador J FIGHT',
};
