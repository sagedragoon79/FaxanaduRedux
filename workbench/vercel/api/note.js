import { read, write, json } from './_store.js';
export async function POST(req) {
  const b = await req.json(), L = await read('notes.json', []);
  if (b.remove) { await write('notes.json', L.filter((n) => n.id !== b.id)); return json({}); }
  const had = b.id && L.find((n) => n.id === b.id);
  if (had) { Object.assign(had, b); await write('notes.json', L); return json(had); }
  const id = 'n' + Date.now().toString(36), n = Object.assign(b, { id, at: new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', timeZone: 'America/New_York' }), ts: Date.now() / 1000, status: 'new', reply: '' });
  L.push(n); await write('notes.json', L); return json(n);
}
