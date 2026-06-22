import { Router } from 'express';
import { query } from '../db.js';

const router = Router();

router.get('/', (_req, res) => {
  res.send('OK');
});

router.post('/', async (req, res) => {
  try {
    const body = req.body;
    const topic = body?.topic ?? body?.type;
    const paymentId = body?.data?.id ?? body?.id;

    if (topic !== 'payment' || !paymentId) {
      return res.send('Ignored');
    }

    const cfg = await query('SELECT mp_access_token FROM financeiro_config WHERE id = 1');
    const mpToken = cfg.rows[0]?.mp_access_token;
    if (!mpToken) return res.send('MP token not configured');

    const mpRes = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: { Authorization: `Bearer ${mpToken}` },
    });
    if (!mpRes.ok) return res.send('MP API error');

    const payment = await mpRes.json();
    const status = payment?.status;
    const preferenciaId = payment?.preference_id;

    if (status !== 'approved' || !preferenciaId) {
      return res.send('Not approved');
    }

    const mens = await query(
      `SELECT id FROM mensalidades WHERE mp_preferencia_id = $1 AND status = 'pendente' LIMIT 1`,
      [preferenciaId],
    );
    if (!mens.rows[0]) return res.send('Mensalidade not found');

    const hoje = new Date().toISOString().split('T')[0];
    await query(
      `UPDATE mensalidades SET status = 'pago', data_pagamento = $1, updated_at = now() WHERE id = $2`,
      [hoje, mens.rows[0].id],
    );

    console.log(`Mensalidade ${mens.rows[0].id} paga via webhook MP`);
    res.send('OK');
  } catch (err) {
    console.error('Webhook MP:', err);
    res.status(500).send('Internal error');
  }
});

export default router;
