#!/bin/bash
# Watchdog script, spends no model tokens. It writes a report and exits when it sees a problem;
# Sheepdog wakes up on that exit. usage: ./watchdog.sh [check-interval-seconds] [silence-limit-minutes]
cd "$(dirname "$0")"; . ./lang.sh; export PYTHONUTF8=1; PY=python3; "$PY" -c "" 2>/dev/null || PY=python
EVERY=${1:-600}; LIMIT=${2:-20}; FAILS=0; touch .watchdog-alive
while :; do
  sleep "$EVERY"; touch .watchdog-alive
  report="$(LIMIT="$LIMIT" "$PY" - <<'PY'
import glob,json,os,re,shutil,subprocess,time
tr=os.environ.get('SHEEPDOG_LANG')=='tr'
def M(a,b): return a if tr else b
limit=int(os.environ['LIMIT'])*60; now=time.time()
try:
    d=json.loads(subprocess.run([os.environ.get('SHEEPDOG_CLAUDE') or shutil.which('claude') or 'claude','agents','--json','--all'],capture_output=True,text=True,timeout=60,stdin=subprocess.DEVNULL).stdout)
    d=d if isinstance(d,list) else d.get('sessions')
    if not isinstance(d,list) or not all(isinstance(s,dict) for s in d): raise ValueError('unexpected JSON shape')
except Exception as e:
    print(M('oturum listesi alınamadı:','could not list sessions:'),e); raise SystemExit
by={}
for s in d: by.setdefault(s.get('name'),[]).append(s)
NORM={'calisiyor':'working','inceleme':'review','dogrulama':'verify','birlesiyor':'merging'}
ACTIVE={'working':'','review':'-reviewer','verify':'-verifier','merging':'-merger'}
for k in sorted(glob.glob('jobs/*/card.md')):
    t=open(k,encoding='utf8').read(); m=re.search(r'^(?:Durum|Status): (.*)$',t,re.M); st=NORM.get(m[1].strip(),m[1].strip()) if m else ''
    a=os.path.basename(os.path.dirname(k))
    if st not in ACTIVE: continue
    age=now-os.path.getmtime(k); o=by.get(a+ACTIVE[st],[])
    if not o:
        print(M(f'{a}: durum {st} ama oturum listede yok',f'{a}: state {st} but the session is not listed')); continue
    s=o[-1]; ss=s.get('state')
    if ss in('failed','stopped'): print(M(f'{a}: durum {st}, oturum {ss}',f'{a}: state {st}, session {ss}')); continue
    if ss=='done' or s.get('status')=='idle':
        if age>limit: print(M(f'{a}: {limit//60} dakikadır durum {st}, oturum boşta; kontrol unutulmuş olabilir',f'{a}: state {st} for {limit//60} minutes and the session is idle; a check may have been forgotten'))
        continue
    f=glob.glob(os.path.expanduser('~/.claude/projects/*/'+s.get('sessionId','none')+'.jsonl'))
    if f and now-os.path.getmtime(f[0])>limit: print(M(f'{a}: {limit//60} dakikadır oturumda hareket yok',f'{a}: no session activity for {limit//60} minutes'))
PY
)"
  # a single failed "claude agents" call does not wake the manager; three in a row do
  case "$report" in "oturum listesi alınamadı"*|"could not list sessions"*) FAILS=$((FAILS+1)); [ "$FAILS" -ge 3 ] || continue;; *) FAILS=0;; esac
  [ -n "$report" ] && { echo "WATCHDOG: $report"; exit 0; }
done
