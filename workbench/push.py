#!/usr/bin/env python3
# Keeps the hosted workbench current: live state up when it changes, the owner's notes down into notes.json, and a media deploy after commits.
# python3 -u workbench/push.py   (leave it running beside server.py)
import hashlib, json, os, subprocess, sys, time, urllib.request
clock = lambda: time.strftime('%I:%M %p').lstrip('0')
HERE = os.path.dirname(os.path.abspath(__file__)); CFG = json.load(open(os.path.join(HERE, 'config.json')))
BASE = CFG['site'].rstrip('/'); PASS = open(os.path.join(HERE, '.wb_pass')).read().strip(); LOCAL = os.path.join(HERE, 'notes.json')
SRV = 'http://127.0.0.1:%d' % CFG.get('port', 8977); EVERY = 60
def call(path, body=None):
    q = urllib.request.Request(BASE + path, data=json.dumps(body).encode() if body is not None else None, headers={'x-wb-pass': PASS, 'Content-Type': 'application/json', 'User-Agent': 'wb-push'})
    return json.load(urllib.request.urlopen(q, timeout=30))
def notes():
    r = call('/api/state?b=%d' % (time.time() // 20))['notes']; L = json.load(open(LOCAL)); by = {n['id']: n for n in L}; add = 0
    for n in r:
        m = by.get(n['id'])
        if not m: L.append(n); add += 1
        elif (m.get('status'), m.get('reply')) != (n.get('status'), n.get('reply')): call('/api/note', {'id': n['id'], 'status': m.get('status'), 'reply': m.get('reply', '')})
    if add:
        json.dump(L, open(LOCAL + '.tmp', 'w'), indent=1); os.replace(LOCAL + '.tmp', LOCAL)
def live(was):
    st = json.load(urllib.request.urlopen(SRV + '/state.json', timeout=10))
    d = {k: st.get(k) for k in ('build', 'owner', 'tasks', 'grades', 'numbers', 'ships', 'dirty', 'running')}
    h = hashlib.sha1(json.dumps(d, sort_keys=True).encode()).hexdigest()
    if h != was:
        d['updated'] = clock(); d['shipAge'] = st.get('shipAge', 0); call('/api/live', d)
    return h, st
def media(st, m):
    # pictures, clips and catalogue need a deploy: soon after a commit, otherwise every half hour (Vercel's free plan allows 100 deploys a day)
    cat = os.path.join(HERE, CFG.get('catalogDir', 'catalog'), 'catalog.json')
    head = st.get('build'); sig = json.dumps([[s['name'] for s in st['shots'][:16]], [c['name'] for c in st['clips']], os.path.getmtime(cat) if os.path.exists(cat) else 0])
    if not m: return {'head': head, 'sig': sig, 'at': time.time()}
    gap = time.time() - m['at']
    if (head != m['head'] and gap > 300) or (sig != m['sig'] and gap > 1800):
        r = subprocess.run([sys.executable, os.path.join(HERE, 'deploy.py')], capture_output=True, text=True); print(clock(), r.stdout.strip()[-120:], r.stderr.strip()[-200:], flush=True)
        return {'head': head, 'sig': sig, 'at': time.time()}
    return m
was = ''; m = None; n = 0
while True:
    try:
        was, st = live(was); m = media(st, m)
        if n % 3 == 0: notes()
        n += 1
    except Exception as e: print(clock(), 'push failed', e, flush=True)
    time.sleep(EVERY)
