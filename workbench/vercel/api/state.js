import { read, json } from './_store.js';
export async function GET() {
  const [live, notes] = await Promise.all([read('live.json', {}), read('notes.json', [])]);
  return json({ live, notes }, { 'Cache-Control': 'public, s-maxage=20' });
}
