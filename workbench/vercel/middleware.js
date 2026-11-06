// the whole site sits behind one password
export const config = { matcher: '/:path*' };
const hash = async (s) => [...new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode('wb:' + s)))].map((b) => b.toString(16).padStart(2, '0')).join('');
const page = (bad) => `<!doctype html><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1"><title>Workbench</title><style>body{margin:0;min-height:100vh;display:grid;place-items:center;background:#14110d;color:#e9dfc9;font:16px Georgia,serif}form{display:grid;gap:12px;width:min(320px,86vw)}h1{font-weight:400;font-size:24px;margin:0 0 6px}input,button{font:inherit;padding:11px 12px;border-radius:6px;border:1px solid #5a4a30;background:#221c14;color:inherit}button{background:#b9913f;color:#17120a;border:0;cursor:pointer}p{color:#d98;margin:0}</style><form method=post action=/__login><h1>Workbench</h1>${bad ? '<p>Wrong password.</p>' : ''}<input type=password name=p placeholder=Password autofocus autocomplete=current-password><button>Open</button></form>`;
const html = (b, s) => new Response(b, { status: s, headers: { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store' } });
export default async function middleware(req) {
  const pass = process.env.WORKBENCH_PASSWORD, u = new URL(req.url);
  if (!pass) return html('<p>Workbench password is not set.', 503);
  if (req.headers.get('x-wb-pass') === pass) return;
  const want = await hash(pass);
  if (u.pathname === '/__login' && req.method === 'POST') {
    const f = await req.formData();
    if (f.get('p') !== pass) return html(page(true), 401);
    return new Response(null, { status: 303, headers: { Location: '/', 'Set-Cookie': `wb=${want}; Path=/; Max-Age=31536000; HttpOnly; Secure; SameSite=Lax` } });
  }
  if ((req.headers.get('cookie') || '').split(/;\s*/).includes('wb=' + want)) return;
  return html(page(false), 401);
}
