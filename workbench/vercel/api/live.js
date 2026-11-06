import { write, json } from './_store.js';
export async function POST(req) { await write('live.json', await req.json()); return json({ ok: true }); }
