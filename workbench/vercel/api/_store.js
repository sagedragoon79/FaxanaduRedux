// live state and notes are two small JSON files in the project's Blob store
import { put } from '@vercel/blob';
const base = () => `https://${process.env.BLOB_READ_WRITE_TOKEN.split('_')[3].toLowerCase()}.public.blob.vercel-storage.com`;
export const read = async (name, none) => { const r = await fetch(`${base()}/${name}?t=${Date.now()}`, { cache: 'no-store' }); return r.ok ? r.json() : none; };
export const write = (name, v) => put(name, JSON.stringify(v), { access: 'public', addRandomSuffix: false, allowOverwrite: true, contentType: 'application/json', cacheControlMaxAge: 60 });
export const json = (o, h) => new Response(JSON.stringify(o), { headers: Object.assign({ 'Content-Type': 'application/json' }, h) });
