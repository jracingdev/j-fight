import jwt from 'jsonwebtoken';
import { config } from './config.js';
import { getUsuario } from './lib/acl.js';

export function signToken(payload) {
  return jwt.sign(payload, config.jwtSecret, { expiresIn: config.jwtExpiresIn });
}

export function verifyToken(token) {
  return jwt.verify(token, config.jwtSecret);
}

export async function authMiddleware(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  req.userId = null;
  req.userEmail = null;
  req.user = null;

  if (!token) return next();

  try {
    const decoded = verifyToken(token);
    req.userId = decoded.sub;
    req.userEmail = decoded.email;
    req.user = await getUsuario(decoded.sub);
    if (!req.user && decoded.email) {
      req.user = { id: decoded.sub, email: decoded.email, role: 'aluno' };
    }
  } catch {
    return res.status(401).json({ error: 'Token inválido ou expirado.' });
  }
  next();
}

export function optionalAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return next();
  return authMiddleware(req, res, next);
}
