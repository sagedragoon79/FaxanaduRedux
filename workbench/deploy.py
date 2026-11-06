#!/usr/bin/env python3
# Builds the hosted workbench from the running local server and deploys it to Vercel: page, catalogue pictures, newest shots and clips.
# python3 workbench/deploy.py   (run from anywhere; needs Pillow, Node, and `npx vercel login` done once)
import base64, io, json, os, re, shutil, subprocess, sys, urllib.parse, urllib.request
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); CFG = json.load(open(os.path.join(HERE, 'config.json')))
at = lambda p: os.path.abspath(os.path.join(HERE, os.path.expanduser(p)))
V = os.path.join(HERE, 'vercel'); PUB = os.path.join(V, 'public'); CAT = at(CFG.get('catalogDir', 'catalog')); LOCAL = 'http://127.0.0.1:%d' % CFG.get('port', 8977)
def uri(src, w, q):
    im = Image.open(src); has = im.mode in ('RGBA', 'LA', 'P') and str(src).lower().endswith('.png'); im = im.convert('RGBA' if has else 'RGB'); im.thumbnail((w, w)); b = io.BytesIO(); im.save(b, 'WEBP', quality=q)
    return 'data:image/webp;base64,' + base64.b64encode(b.getvalue()).decode()
c = {}
if os.path.exists(CAT + '/catalog.json'):
    c = json.load(open(CAT + '/catalog.json'))
    for s in c.get('sections', []):
        w, q = (760, 60) if s.get('layout') == 'wide' else (260, 68)
        for r in s.get('rows', []):
            if r.get('img'): r['img'] = uri(os.path.join(CAT, r['img']), w, q)
st = json.load(urllib.request.urlopen(LOCAL + '/state.json', timeout=30))
shots = []
for s in st['shots'][:16]:
    try: shots.append({'url': uri(io.BytesIO(urllib.request.urlopen(LOCAL + s['url'], timeout=20).read()), 960, 62), 'name': s['name'], 'age': 0})
    except Exception as e: print('skip shot', s['name'], e)
shutil.rmtree(PUB, ignore_errors=True); os.makedirs(PUB + '/clips')
clips = []; D = at(CFG.get('clipDir', 'clips'))
for x in st['clips']:
    f = urllib.parse.unquote(x['url'][6:]); p = os.path.join(D, f)
    if f.lower().endswith('.gif') or os.path.getsize(p) > 15e6: continue   # the page plays video; GIFs and huge files only slow it
    shutil.copy(p, PUB + '/clips/' + f); clips.append({'url': 'clips/' + urllib.parse.quote(f), 'name': f, 'video': True, 'age': 0})
json.dump({'cat': c, 'shots': shots, 'clips': clips, 'cfg': {k: CFG.get(k) for k in ('game', 'theme')}}, open(PUB + '/data.json', 'w'))
t = open(os.path.join(HERE, 'index.html')).read(); shim = open(os.path.join(V, 'shim.html')).read()
a = "const img = (p) => '/cat/' + encodeURI(p),"; assert a in t; t = t.replace(a, "const img = (p) => p,")
i = t.index('<script>'); t = t[:i] + shim + t[i:]
open(PUB + '/index.html', 'w').write(t)
if '--build-only' in sys.argv: print('built', PUB, len(shots), 'shots,', len(clips), 'clips'); sys.exit(0)
vc = ['npx', '-y', 'vercel@latest']
subprocess.run(vc + ['deploy', '--prod', '--yes', '--no-color'], cwd=V, check=True, capture_output=True)
ls = subprocess.run(vc + ['ls', '--no-color'], cwd=V, capture_output=True, text=True); host = urllib.parse.urlparse(CFG.get('site', '')).hostname or ''
name = host.split('.')[0]; L = list(dict.fromkeys(re.findall(r'https://%s-\S+\.vercel\.app' % re.escape(name), ls.stdout + ls.stderr))) if name else []
for u in L[1:]: subprocess.run(vc + ['rm', u, '--yes', '--no-color'], cwd=V, capture_output=True)   # old deployments count against storage
print('deployed', len(shots), 'shots,', len(clips), 'clips; removed', max(0, len(L) - 1), 'old deployments')
