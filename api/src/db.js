import pg from 'pg';
import { config } from './config.js';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: config.databaseUrl,
  max: 20,
});

pool.on('error', (err) => {
  console.error('PostgreSQL pool error:', err);
});

export async function query(text, params) {
  return pool.query(text, params);
}
