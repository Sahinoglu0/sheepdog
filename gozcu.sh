#!/bin/bash
# Takip betiği, model harcamaz. Sorun görünce rapor yazıp çıkar; Sheepdog bu çıkışla uyanır.
# kullanım: ./gozcu.sh [kontrol-aralığı-sn] [sessizlik-sınırı-dk]
cd "$(dirname "$0")"; export PYTHONUTF8=1; PY=python3; "$PY" -c "" 2>/dev/null || PY=python; ARA=${1:-600}; SINIR=${2:-20}; HATA=0; touch .gozcu-yasam
while :; do
  sleep "$ARA"; touch .gozcu-yasam
  rapor="$(SINIR="$SINIR" "$PY" - <<'PY'
import glob,json,os,re,shutil,subprocess,time
sinir=int(os.environ['SINIR'])*60; simdi=time.time()
try:
    d=json.loads(subprocess.run([shutil.which('claude') or 'claude','agents','--json','--all'],capture_output=True,text=True,timeout=60,stdin=subprocess.DEVNULL).stdout)
except Exception as e:
    print('oturum listesi alınamadı:',e); raise SystemExit
d=d if isinstance(d,list) else d.get('sessions',d)
ad={}
for s in d: ad.setdefault(s.get('name'),[]).append(s)
AKTIF={'calisiyor':'','inceleme':'-reviewer','dogrulama':'-dogrulayici','birlesiyor':'-birlestirici'}
for k in sorted(glob.glob('isler/*/kart.md')):
    t=open(k,encoding='utf8').read(); m=re.search(r'^Durum: (.*)$',t,re.M); durum=m[1].strip() if m else ''
    a=os.path.basename(os.path.dirname(k))
    if durum not in AKTIF: continue
    yas=simdi-os.path.getmtime(k); o=ad.get(a+AKTIF[durum],[])
    if not o:
        print(f'{a}: durum {durum} ama oturum listede yok'); continue
    s=o[-1]; st=s.get('state')
    if st in('failed','stopped'): print(f'{a}: durum {durum}, oturum {st}'); continue
    if st=='done' or s.get('status')=='idle':
        if yas>sinir: print(f'{a}: {sinir//60} dakikadır durum {durum}, oturum boşta; kontrol unutulmuş olabilir')
        continue
    f=glob.glob(os.path.expanduser('~/.claude/projects/*/'+s.get('sessionId','yok')+'.jsonl'))
    if f and simdi-os.path.getmtime(f[0])>sinir: print(f'{a}: {sinir//60} dakikadır oturumda hareket yok')
PY
)"
  case "$rapor" in "oturum listesi alınamadı"*) HATA=$((HATA+1)); [ "$HATA" -ge 3 ] || continue;; *) HATA=0;; esac
  [ -n "$rapor" ] && { echo "GOZCU: $rapor"; exit 0; }
done
