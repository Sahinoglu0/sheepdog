#!/usr/bin/env python3
"""Generates the animated SVG artwork (English and Turkish) into assets/<lang>/.
Style: a golden-hour pasture illustration (hills, sheep, a sheepdog, a pen), not UI boxes.
usage: python3 tools/build_assets.py"""
import math
import os

SKY1, SKY2, SKY3 = "#1b1140", "#6b2a7a", "#ff8a5c"
CREAM, GOLD, CORAL, MINT = "#fff4e0", "#ffc857", "#ff7a59", "#7ee0b5"
PLUM, DEEP = "#2b1b4a", "#140c2b"
FONT = "ui-rounded,'SF Pro Rounded','Nunito','Trebuchet MS',system-ui,-apple-system,'Segoe UI',sans-serif"

TXT = {
 "en": {
  "tagline1": "One agent herds every", "tagline2": "Claude Code session.",
  "sub": "dispatches · reviews · merges what passes",
  "foot": "every job in its own project, in its own session",
  "banner_alt": "Sheepdog",
  "stages": [("card", "done-criteria"), ("worker", "does the job"), ("reviewer", "was it done?"), ("verifier", "runs checks"), ("dry run", "conflicts?"), ("merger", "lands it"), ("main", "tests passed")],
  "flow_back": "incomplete work returns to the same worker  ·  after 3 rounds the decision is yours",
  "watch": "watchdog  ·  checks every 10 min  ·  reports closed or stuck sessions",
  "flow_title": "How a card travels",
  "states": [("draft", "you write"), ("ready", "you approve"), ("working", "worker"), ("review", "reviewer"), ("verify", "verifier"), ("merge-queue", "dry run clean"), ("merging", "merger"), ("done", "on main")],
  "stuck": "stuck: needs a human or an environment fix",
  "life_title": "Card lifecycle", "life_sub": "Only state.sh changes a card's state. Workers never do.",
  "life_back": "failed checks send findings back to the same worker  ·  max 3 rounds",
  "demo_title": "sheepdog  ·  one conversation",
  "demo": [("you", "Ask me before merging. Start the ready cards."),
           ("dog", "Started the worker for 001-empty-email-crash."),
           ("dog", "Worker finished. Review started."),
           ("dog", "Review passed. Verifier started."),
           ("dog", "Verified. Dry run clean (1 commit). Merge into main?"),
           ("you", "Yes, merge it."),
           ("ok", "Done: worktree-card-001 entered main as e99b19e.")],
  "online": "online", "legend_flock": "projects", "arch_title": "One door in, many sessions out",
  "arch_you": "you", "arch_dog": "Sheepdog", "arch_dog2": "the only agent you talk to",
  "arch_roles": [("worker", "own project, own branch"), ("reviewer", "did not do the work"), ("verifier", "re-runs the checks"), ("merger", "ff-only into main")],
  "arch_scripts": ["board", "watchdog", "dry-run", "state"], "arch_scripts_t": "scripts · zero model tokens",
  "safety_title": "Defense in layers", "safety_sub": "narrows the blast radius; it is not a sandbox",
  "safety": [("Rules in the prompts", "no push, no .env, no state edits"), ("Scoped access", "a session sees only its own card folder"), ("Validated launch", "model and effort checked before start"), ("Git guardrails", "dry run, throwaway worktree, fast-forward only"), ("Your OS account / container", "the layer that is actually a wall")],
 },
 "tr": {
  "tagline1": "Tek ajan bütün", "tagline2": "Claude Code oturumlarını güder.",
  "sub": "dağıtır · kontrol ettirir · geçeni birleştirir",
  "foot": "her iş kendi projesinde, kendi oturumunda",
  "banner_alt": "Sheepdog",
  "stages": [("kart", "bitti şartı"), ("işçi", "işi yapar"), ("incelemeci", "yapıldı mı?"), ("doğrulayıcı", "kontrol koşar"), ("prova", "çakışma?"), ("birleştirici", "ekler"), ("main", "testler geçti")],
  "flow_back": "eksik iş aynı işçiye döner  ·  3 turda geçmezse karar sizde",
  "watch": "gözcü  ·  10 dakikada bir bakar  ·  kapanan veya takılan oturumu bildirir",
  "flow_title": "Bir kart nasıl ilerler",
  "states": [("taslak", "siz yazarsınız"), ("hazır", "siz onaylarsınız"), ("çalışıyor", "işçi"), ("inceleme", "incelemeci"), ("doğrulama", "doğrulayıcı"), ("birleşme sırası", "prova temiz"), ("birleşiyor", "birleştirici"), ("bitti", "main'de")],
  "stuck": "tıkandı: insan ya da ortam düzeltmesi gerekir",
  "life_title": "Kartın yaşam döngüsü", "life_sub": "Kart durumunu yalnız state.sh değiştirir. İşçiler değiştirmez.",
  "life_back": "başarısız kontrol bulguları aynı işçiye geri gönderir  ·  en çok 3 tur",
  "demo_title": "sheepdog  ·  tek konuşma",
  "demo": [("you", "Birleştirmeden önce bana sor. Hazır kartları başlat."),
           ("dog", "001-bos-eposta-cokmesi için işçiyi başlattım."),
           ("dog", "İşçi bitirdi. İnceleme başladı."),
           ("dog", "İnceleme geçti. Doğrulayıcı başladı."),
           ("dog", "Doğrulandı. Prova temiz (1 commit). main'e birleştireyim mi?"),
           ("you", "Evet, birleştir."),
           ("ok", "Bitti: worktree-kart-001 main'e e99b19e ile girdi.")],
  "online": "çevrimiçi", "legend_flock": "projeler", "arch_title": "Tek kapı, çok oturum",
  "arch_you": "siz", "arch_dog": "Sheepdog", "arch_dog2": "konuştuğunuz tek ajan",
  "arch_roles": [("işçi", "kendi proje ve dalında"), ("incelemeci", "işi yapmamış ajan"), ("doğrulayıcı", "kontrolleri yeniden koşar"), ("birleştirici", "main'e yalnız ileri sarar")],
  "arch_scripts": ["board", "watchdog", "dry-run", "state"], "arch_scripts_t": "betikler · sıfır model harcaması",
  "safety_title": "Katmanlı koruma", "safety_sub": "etki alanını daraltır; güvenlik kutusu değildir",
  "safety": [("İstemlerdeki kurallar", "push yok, .env yok, durum değiştirme yok"), ("Daraltılmış erişim", "oturum yalnız kendi kart klasörünü görür"), ("Doğrulanmış başlatma", "model ve efor başlamadan kontrol edilir"), ("Git korkulukları", "prova, geçici worktree, yalnız ileri sarma"), ("İşletim sistemi hesabınız / kapsayıcı", "gerçekten duvar olan katman")],
 },
}


def svg(w, h, title, desc, inner, css="", sky=True):
    bg = f'<rect width="{w}" height="{h}" rx="26" fill="url(#sky)"/>' if sky else ""
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-labelledby="t d">
<title id="t">{title}</title><desc id="d">{desc}</desc>
<style>
text{{font-family:{FONT}}}
.cream{{fill:{CREAM}}} .gold{{fill:{GOLD}}} .coral{{fill:{CORAL}}} .mint{{fill:{MINT}}} .soft{{fill:{CREAM};fill-opacity:.72}}
.tw{{animation:tw 3s ease-in-out infinite}} @keyframes tw{{0%,100%{{opacity:.15}}50%{{opacity:1}}}}
.pulse{{animation:pl 2.6s ease-in-out infinite}} @keyframes pl{{0%,100%{{opacity:1}}50%{{opacity:.3}}}}
.wag{{transform-box:fill-box;transform-origin:0% 100%;animation:wag .9s ease-in-out infinite alternate}} @keyframes wag{{from{{transform:rotate(-14deg)}}to{{transform:rotate(22deg)}}}}
.ear{{transform-box:fill-box;transform-origin:50% 100%;animation:ear 4s ease-in-out infinite}} @keyframes ear{{0%,88%,100%{{transform:rotate(0)}}92%{{transform:rotate(-16deg)}}96%{{transform:rotate(4deg)}}}}
.dash{{stroke-dasharray:7 9;animation:dsh 1.6s linear infinite}} @keyframes dsh{{to{{stroke-dashoffset:-32}}}}
{css}
@media (prefers-reduced-motion:reduce){{*{{animation:none!important}}}}
</style>
<defs>
<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{SKY1}"/><stop offset=".55" stop-color="{SKY2}"/><stop offset="1" stop-color="{SKY3}"/></linearGradient>
<radialGradient id="sun" cx=".5" cy=".5" r=".5"><stop offset="0" stop-color="#fff2b0"/><stop offset=".45" stop-color="{GOLD}"/><stop offset="1" stop-color="{GOLD}" stop-opacity="0"/></radialGradient>
<linearGradient id="grass" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#1d5a52"/><stop offset="1" stop-color="#0c2a33"/></linearGradient>
<linearGradient id="gold" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="{GOLD}"/><stop offset="1" stop-color="{CORAL}"/></linearGradient>
<clipPath id="card"><rect width="{w}" height="{h}" rx="26"/></clipPath>
</defs>
{bg}
<g clip-path="url(#card)">{inner}</g>
</svg>"""

def stars(w, h, n, seed=7):
    out = []; s = seed
    for i in range(n):
        s = (s * 1103515245 + 12345) % 2147483648; x = s % w
        s = (s * 1103515245 + 12345) % 2147483648; y = s % int(h * .45)
        out.append(f'<circle class="tw" cx="{x}" cy="{y}" r="{1 + (i % 3) * .5}" fill="{CREAM}" style="animation-delay:{(i * .37) % 3:.2f}s"/>')
    return "".join(out)

def cloud(x, y, s=1.0, dur=90, delay=0, op=.18):
    return (f'<g opacity="{op}"><g><animateTransform attributeName="transform" type="translate" values="-260 0;1500 0" dur="{dur}s" begin="{delay}s" repeatCount="indefinite"/>'
            f'<g transform="translate({x},{y}) scale({s})" fill="{CREAM}"><ellipse cx="0" cy="0" rx="60" ry="16"/><circle cx="-18" cy="-14" r="20"/><circle cx="14" cy="-20" r="26"/><circle cx="40" cy="-8" r="16"/></g></g></g>')

def hills(w, h, y0):
    far = f'<path d="M0 {y0} C150 {y0-50} 300 {y0+10} 470 {y0-20} S800 {y0-70} 1000 {y0-20} S1150 {y0-40} {w} {y0-10} L{w} {h} L0 {h}Z" fill="#4a2a78"/>'
    mid = f'<path d="M0 {y0+40} C200 {y0-10} 380 {y0+70} 600 {y0+30} S980 {y0-20} {w} {y0+40} L{w} {h} L0 {h}Z" fill="#2f1e5c"/>'
    near = f'<path d="M0 {y0+90} C240 {y0+40} 460 {y0+120} 700 {y0+80} S1050 {y0+50} {w} {y0+95} L{w} {h} L0 {h}Z" fill="url(#grass)"/>'
    return far + mid + near

def sheep(x, y, s=1.0, bob=0.0, c=CREAM, face=PLUM):
    r = 9
    puffs = "".join(f'<circle cx="{dx*r:.1f}" cy="{dy*r:.1f}" r="{r*.68:.1f}" fill="{c}"/>' for dx, dy in ((-1.0,-.1),(-.5,-.85),(.35,-.9),(1.0,-.2),(-.7,.5),(.3,.65),(.95,.45)))
    legs = f'<rect x="{-r*.7}" y="{r*.8}" width="3" height="{r*.9}" rx="1.5" fill="{face}"/><rect x="{r*.5}" y="{r*.8}" width="3" height="{r*.9}" rx="1.5" fill="{face}"/>'
    head = f'<ellipse cx="{r*1.45}" cy="{r*.05}" rx="{r*.62}" ry="{r*.55}" fill="{face}"/><circle cx="{r*1.55}" cy="{-r*.1}" r="1.4" fill="{CREAM}"/>'
    anim = f'<animateTransform attributeName="transform" type="translate" values="0 0;0 -3;0 0" dur="0.8s" begin="{bob}s" repeatCount="indefinite"/>'
    return f'<g transform="translate({x},{y}) scale({s})"><g>{anim}{legs}{puffs}<circle r="{r}" fill="{c}"/>{head}</g></g>'

def walker(path_id, dur, begin, s=1.0, c=CREAM):
    return f'<g><animateMotion dur="{dur}s" begin="{begin}s" repeatCount="indefinite" rotate="0"><mpath href="#{path_id}"/></animateMotion>{sheep(0, 0, s, begin * .13, c)}</g>'

def dog(x, y, s=1.0, flip=False):
    sx = -s if flip else s
    return f"""<g transform="translate({x},{y}) scale({sx},{s})">
<path class="wag" d="M-30 18 C-60 14 -70 -8 -62 -26" fill="none" stroke="{DEEP}" stroke-width="9" stroke-linecap="round"/>
<ellipse cx="-2" cy="4" rx="36" ry="42" fill="{DEEP}"/>
<ellipse cx="14" cy="14" rx="16" ry="28" fill="{CREAM}"/>
<ellipse cx="-24" cy="40" rx="18" ry="11" fill="{DEEP}"/>
<rect x="12" y="30" width="11" height="30" rx="5" fill="{CREAM}"/><rect x="-4" y="30" width="11" height="30" rx="5" fill="{DEEP}"/>
<circle cx="24" cy="-44" r="24" fill="{DEEP}"/>
<path class="ear" d="M8 -62 L2 -92 Q22 -84 28 -64 Z" fill="{DEEP}"/>
<path d="M34 -64 L46 -90 Q56 -76 50 -58 Z" fill="#0b0720"/>
<ellipse cx="42" cy="-36" rx="16" ry="12" fill="{CREAM}"/>
<ellipse cx="54" cy="-40" rx="5" ry="4" fill="{DEEP}"/>
<circle cx="30" cy="-52" r="3.4" fill="{CREAM}"/><circle cx="31" cy="-52" r="1.5" fill="{DEEP}"/>
<path d="M6 -26 Q22 -14 38 -22" fill="none" stroke="{GOLD}" stroke-width="5" stroke-linecap="round"/>
</g>"""

DOGS = None

def pen(x, y, w, hgt, label, gate_open=True):
    posts = "".join(f'<rect x="{x+i*w/5-3:.1f}" y="{y-6}" width="6" height="{hgt+6}" rx="2" fill="{GOLD}"/>' for i in range(6))
    rails = f'<rect x="{x}" y="{y+8}" width="{w}" height="5" rx="2" fill="{GOLD}" opacity=".9"/><rect x="{x}" y="{y+hgt*.5}" width="{w}" height="5" rx="2" fill="{GOLD}" opacity=".9"/>'
    sign = f'<g><rect x="{x+w/2-34}" y="{y-40}" width="68" height="26" rx="8" fill="{PLUM}" stroke="{GOLD}" stroke-width="2"/><text x="{x+w/2}" y="{y-22}" text-anchor="middle" class="gold" font-size="15" font-weight="800">{label}</text></g>'
    return f'<g>{rails}{posts}{sign}</g>'

def banner(L, t):
    w, h = 1200, 420
    o = stars(w, h, 46) + f'<circle cx="930" cy="246" r="120" fill="url(#sun)"><animate attributeName="cy" values="246;238;246" dur="8s" repeatCount="indefinite"/></circle>'
    o += cloud(0, 70, 1.0, 95, 0) + cloud(0, 120, .7, 120, -50) + cloud(0, 44, .6, 140, -90)
    o += hills(w, h, 262)
    # trail the flock follows
    o += '<path id="trail" d="M-40 352 C140 330 260 372 430 350 S700 318 860 338 S940 334 980 330" fill="none"/>'
    o += pen(940, 286, 196, 70, "main")
    for i, (dur, b) in enumerate(((16, 0), (16, -4), (16, -8), (16, -12))):
        o += walker("trail", dur, b, .95)
    o += dog(560, 356, .9)
    o += f'<text x="64" y="132" class="cream" font-size="88" font-weight="900" letter-spacing="-3">Sheepdog</text>'
    o += f'<text x="66" y="190" class="cream" font-size="31" font-weight="700">{t["tagline1"]}</text>'
    o += f'<text x="66" y="230" fill="url(#gold)" font-size="31" font-weight="800">{t["tagline2"]}</text>'
    o += f'<text x="66" y="276" class="soft" font-size="19">{t["sub"]}</text>'
    return svg(w, h, "Sheepdog", t["tagline1"] + " " + t["tagline2"], o)

def smooth(pts):
    d = f"M{pts[0][0]} {pts[0][1]}"
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        dx = (x1 - x0) * .5
        d += f" C{x0+dx} {y0} {x1-dx} {y1} {x1} {y1}"
    return d

def flow(L, t):
    w, h = 1200, 400
    o = stars(w, h, 30, 3) + cloud(0, 60, .8, 110, -20) + hills(w, h, 250)
    n = len(t["stages"])
    ys = [292, 262, 296, 262, 298, 264, 292]
    xs = [90 + i * ((w - 180) / (n - 1)) for i in range(n)]
    pts = list(zip(xs, ys))
    d = smooth(pts)
    o += f'<path d="{d}" fill="none" stroke="{DEEP}" stroke-width="22" stroke-linecap="round" opacity=".55"/>'
    o += f'<path id="path" d="{d}" fill="none" stroke="{GOLD}" stroke-width="4" stroke-dasharray="2 12" stroke-linecap="round"/>'
    kinds = ["end", "agent", "agent", "agent", "script", "agent", "ok"]
    for i, ((nm, sub), (x, y), k) in enumerate(zip(t["stages"], pts, kinds)):
        col = {"end": CREAM, "agent": GOLD, "script": MINT, "ok": MINT}[k]
        o += f'<rect x="{x-3}" y="{y-64}" width="6" height="64" rx="3" fill="#7a4f2a"/>'
        pw = 138
        o += f'<g><rect x="{x-pw/2}" y="{y-104}" width="{pw}" height="46" rx="10" fill="{PLUM}" stroke="{col}" stroke-width="2.5"/><text x="{x}" y="{y-80}" text-anchor="middle" fill="{col}" font-size="17" font-weight="800">{nm}</text><text x="{x}" y="{y-64}" text-anchor="middle" class="soft" font-size="11.5">{sub}</text></g>'
        o += f'<circle cx="{x}" cy="{y}" r="7" fill="{col}"/>'
    o += f'<g><animateMotion dur="12s" repeatCount="indefinite" rotate="0"><mpath href="#path"/></animateMotion>{sheep(0, -6, 1.2)}</g>'
    # return loop below
    a = pts[1]; b = pts[5]
    o += f'<path d="M{b[0]} {b[1]+16} C{b[0]-80} {b[1]+86} {a[0]+80} {a[1]+86} {a[0]} {a[1]+16}" fill="none" stroke="{CORAL}" stroke-width="3" class="dash"/>'
    o += f'<path d="M{a[0]-7} {a[1]+28} L{a[0]} {a[1]+14} L{a[0]+8} {a[1]+27}" fill="none" stroke="{CORAL}" stroke-width="3" stroke-linecap="round"/>'
    o += f'<text x="{(a[0]+b[0])/2}" y="{h-18}" text-anchor="middle" class="coral" font-size="16" font-weight="700">{t["flow_back"]}</text>'
    # watchtower
    tx = 640; ty = 58
    o += f'<rect x="{tx-9}" y="{ty}" width="18" height="50" fill="#7a4f2a"/><rect x="{tx-20}" y="{ty-18}" width="40" height="22" rx="4" fill="{PLUM}" stroke="{GOLD}" stroke-width="2"/><path d="M{tx-26} {ty-18} L{tx} {ty-40} L{tx+26} {ty-18}Z" fill="{CORAL}"/>'
    o += f'<circle class="pulse" cx="{tx}" cy="{ty-7}" r="6" fill="{GOLD}"/><path class="pulse" d="M{tx-6} {ty-7} L{tx-120} {ty+44} L{tx-120} {ty-26}Z" fill="{GOLD}" opacity=".09"/><path class="pulse" d="M{tx+6} {ty-7} L{tx+120} {ty+44} L{tx+120} {ty-26}Z" fill="{GOLD}" opacity=".09"/>'
    o += f'<text x="{tx+130}" y="{ty+4}" class="soft" font-size="13">{t["watch"].split("  ·  ")[0]}  ·  {t["watch"].split("  ·  ")[1]}</text>'
    o += f'<text x="48" y="48" class="cream" font-size="25" font-weight="800">{t["flow_title"]}</text>'
    return svg(w, h, t["flow_title"], t["flow_title"], o)

def lifecycle(L, t):
    w, h = 1200, 460
    cx, cy, r = 600, 238, 150
    css = ""
    n = 8
    o = stars(w, h, 36, 11) + cloud(0, 70, .7, 130, -40)
    o += f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{CREAM}" stroke-opacity=".22" stroke-width="22"/><circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{GOLD}" stroke-width="3" stroke-dasharray="2 11" stroke-linecap="round"/>'
    pos = []
    for i in range(n):
        a = math.radians(-90 + i * 360 / n)
        pos.append((cx + r * math.cos(a), cy + r * math.sin(a), a))
    for i, ((nm, sub), (x, y, a)) in enumerate(zip(t["states"], pos)):
        human = i in (0, 1); done = i == n - 1
        col = CREAM if human else (MINT if done else GOLD)
        o += f'<circle cx="{x:.1f}" cy="{y:.1f}" r="19" fill="{PLUM}" stroke="{col}" stroke-width="3"/><text x="{x:.1f}" y="{y+6:.1f}" text-anchor="middle" fill="{col}" font-size="16" font-weight="800">{i+1}</text>'
        lx = x + 40 * math.cos(a); ly = y + 40 * math.sin(a)
        anchor = "middle" if abs(math.cos(a)) < .3 else ("start" if math.cos(a) > 0 else "end")
        if anchor == "middle": ly = ly + (8 if math.sin(a) > 0 else -2)
        o += f'<text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anchor}" class="cream" font-size="18" font-weight="800">{nm}</text><text x="{lx:.1f}" y="{ly+18:.1f}" text-anchor="{anchor}" class="soft" font-size="13">{sub}</text>'
    # return arcs to "working" (index 2)
    wk = pos[2]
    for idx in (3, 4, 6):
        px, py, _ = pos[idx]
        o += f'<path d="M{px:.1f} {py:.1f} Q{cx} {cy} {wk[0]:.1f} {wk[1]:.1f}" fill="none" stroke="{CORAL}" stroke-width="2.2" class="dash" opacity=".85"/>'
    # orbiting lamb
    o += f'<path id="ring" d="M{cx} {cy-r} A{r} {r} 0 1 1 {cx-.01} {cy-r}" fill="none"/>'
    o += f'<g><animateMotion dur="20s" repeatCount="indefinite" rotate="0"><mpath href="#ring"/></animateMotion>{sheep(0,-4,1.15)}</g>'
    o += dog(cx - 6, cy + 8, .75)
    o += f'<text x="48" y="50" class="cream" font-size="25" font-weight="800">{t["life_title"]}</text><text x="48" y="78" class="soft" font-size="14.5">{t["life_sub"]}</text>'
    o += f'<text x="{w-48}" y="50" text-anchor="end" class="coral" font-size="15" font-weight="700">{t["life_back"]}</text>'
    o += f'<circle class="pulse" cx="48" cy="{h-31}" r="6" fill="{GOLD}"/><text x="62" y="{h-26}" class="soft" font-size="14">{t["stuck"]}</text>'
    return svg(w, h, t["life_title"], t["life_title"], o)

def demo(L, t):
    w, h = 1000, 470
    lines = t["demo"]; n = len(lines); total = 24
    css = ""
    for i in range(n):
        a = 1 + i * 2.8
        css += f".b{i}{{opacity:0;animation:b{i} {total}s ease-out infinite;transform-box:fill-box;transform-origin:{'100%' if lines[i][0]=='you' else '0%'} 100%}}@keyframes b{i}{{0%,{a/total*100:.2f}%{{opacity:0;transform:scale(.85) translateY(10px)}}{(a+.6)/total*100:.2f}%,94%{{opacity:1;transform:none}}98%,100%{{opacity:0}}}}"
    o = stars(w, h, 24, 5) + f'<rect x="0" y="0" width="{w}" height="64" fill="{DEEP}" fill-opacity=".55"/>'
    o += f'<circle cx="44" cy="32" r="20" fill="{PLUM}" stroke="{GOLD}" stroke-width="2"/><g transform="translate(44,30) scale(.2)">{DOGS}</g>'
    o += f'<text x="76" y="30" class="cream" font-size="18" font-weight="800">Sheepdog</text><circle class="pulse" cx="80" cy="46" r="4" fill="{MINT}"/><text x="90" y="50" class="soft" font-size="12.5">{t["online"]}</text>'
    y = 92
    for i, (who, txt) in enumerate(lines):
        tw = min(860, 44 + len(txt) * 8.6)
        if who == "you":
            x = w - 40 - tw; fill = GOLD; tc = DEEP
        else:
            x = 40; fill = CREAM if who == "dog" else MINT; tc = DEEP
        o += f'<g class="b{i}"><rect x="{x:.1f}" y="{y}" width="{tw:.1f}" height="44" rx="22" fill="{fill}"/><text x="{x+22:.1f}" y="{y+28}" fill="{tc}" font-size="16.5" font-weight="{"700" if who!="dog" else "600"}">{txt}</text></g>'
        y += 54
    return svg(w, h, t["demo_title"], t["demo_title"], o, css)

def arch(L, t):
    w, h = 1200, 500
    o = f'<rect width="{w}" height="{h}" fill="url(#grass)"/>'
    o += "".join(f'<circle cx="{(i*97)%w}" cy="{(i*53)%h}" r="2" fill="#2a8c6a" opacity=".35"/>' for i in range(60))
    bx, by = 535, 235
    fields = [(220, 120), (850, 120), (220, 372), (850, 372)]
    colors = [GOLD, MINT, CORAL, CREAM]
    for (nm, sub), (fx, fy), c in zip(t["arch_roles"], fields, colors):
        o += f'<rect x="{fx-130}" y="{fy-62}" width="260" height="124" rx="26" fill="#0c3a3a" stroke="{c}" stroke-width="3" stroke-dasharray="3 9" stroke-linecap="round"/>'
        o += f'<text x="{fx}" y="{fy-8}" text-anchor="middle" fill="{c}" font-size="24" font-weight="900">{nm}</text><text x="{fx}" y="{fy+18}" text-anchor="middle" class="soft" font-size="14">{sub}</text>'
        o += sheep(fx - 70, fy + 44, .8, fx % 7 * .1) + sheep(fx + 66, fy + 46, .7, .3)
        pid = f"p{fx}{fy}"
        o += f'<path id="{pid}" d="M{bx} {by} Q{(bx+fx)/2} {by if fy>by else by} {fx} {fy+ (62 if fy<by else -62)}" fill="none" stroke="{GOLD}" stroke-opacity=".6" stroke-width="3" stroke-dasharray="3 10" stroke-linecap="round"/>'
        o += f'<g><animateMotion dur="7s" begin="{(fx+fy)%5*.7}s" repeatCount="indefinite" rotate="0"><mpath href="#{pid}"/></animateMotion>{sheep(0,-4,.8)}</g>'
    # barn
    o += f'<rect x="{bx-74}" y="{by-52}" width="148" height="104" rx="8" fill="{CORAL}"/><path d="M{bx-88} {by-48} L{bx} {by-110} L{bx+88} {by-48}Z" fill="#b8452f"/><rect x="{bx-26}" y="{by}" width="52" height="52" rx="6" fill="{PLUM}"/><path d="M{bx-26} {by} L{bx+26} {by+52} M{bx+26} {by} L{bx-26} {by+52}" stroke="{CREAM}" stroke-width="3"/>'
    o += f'<g transform="translate({bx},{by-76}) scale(.42)">{DOGS}</g>'
    o += f'<text x="{bx}" y="{by+84}" text-anchor="middle" class="cream" font-size="22" font-weight="900">{t["arch_dog"]}</text><text x="{bx}" y="{by+104}" text-anchor="middle" class="soft" font-size="13">{t["arch_dog2"]}</text>'
    # you: farmer at left edge
    o += f'<circle cx="60" cy="{by}" r="26" fill="{CREAM}"/><path d="M36 {by-16} Q60 {by-46} 84 {by-16}Z" fill="{GOLD}"/><rect x="30" y="{by-18}" width="60" height="6" rx="3" fill="{GOLD}"/><text x="60" y="{by+52}" text-anchor="middle" class="cream" font-size="16" font-weight="800">{t["arch_you"]}</text>'
    o += f'<path d="M92 {by} L{bx-90} {by}" stroke="{CREAM}" stroke-width="3" class="dash" stroke-linecap="round"/>'
    # fence of lanterns (scripts)
    for i, s in enumerate(t["arch_scripts"]):
        lx = 600 + (i - 1.5) * 76
        o += f'<rect x="{lx-3}" y="{h-82}" width="6" height="46" fill="#7a4f2a"/><circle class="pulse" cx="{lx}" cy="{h-92}" r="9" fill="{GOLD}" style="animation-delay:{i*.5}s"/><text x="{lx}" y="{h-20}" text-anchor="middle" class="cream" font-size="14" font-weight="700">{s}</text>'
    o += f'<text x="{w-40}" y="{h-20}" text-anchor="end" class="soft" font-size="13">{t["arch_scripts_t"]}</text>'
    o += f'<text x="48" y="50" class="cream" font-size="25" font-weight="800">{t["arch_title"]}</text>'
    return svg(w, h, t["arch_title"], t["arch_title"], o, sky=False)

def safety(L, t):
    w, h = 1200, 470
    cx, cy = 290, 262
    css = ""
    for i in range(5):
        css += f".r{i}{{animation:rp 6s ease-in-out infinite;animation-delay:{(4-i)*.5}s}}"
    css += "@keyframes rp{0%,100%{opacity:.55}20%{opacity:1}}"
    o = stars(w, h, 34, 17) + hills(w, h, 330)
    cols = [CORAL, GOLD, MINT, "#8ec5ff", CREAM]
    sizes = [(250, 170), (208, 141), (166, 112), (124, 83), (82, 54)]
    for i, ((rx, ry), c) in enumerate(zip(sizes, cols)):
        o += f'<ellipse class="r{i}" cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{c}" fill-opacity=".08" stroke="{c}" stroke-width="3.5" stroke-dasharray="3 10" stroke-linecap="round"/>'
    o += sheep(cx - 18, cy + 8, 1.4) + sheep(cx + 22, cy + 14, 1.1, .3)
    for i, ((nm, sub), c) in enumerate(zip(t["safety"], cols)):
        yy = 112 + i * 66
        rx, ry = sizes[i]
        o += f'<circle cx="{cx}" cy="{cy-ry:.1f}" r="13" fill="{PLUM}" stroke="{c}" stroke-width="3"/><text x="{cx}" y="{cy-ry+5:.1f}" text-anchor="middle" fill="{c}" font-size="14" font-weight="900">{i+1}</text>'
        o += f'<circle cx="590" cy="{yy-4}" r="14" fill="{PLUM}" stroke="{c}" stroke-width="3"/><text x="590" y="{yy+2}" text-anchor="middle" fill="{c}" font-size="15" font-weight="900">{i+1}</text>'
        o += f'<text x="618" y="{yy-6}" fill="{c}" font-size="19" font-weight="800">{nm}</text><text x="618" y="{yy+16}" class="soft" font-size="14">{sub}</text>'
    o += f'<text x="48" y="50" class="cream" font-size="25" font-weight="800">{t["safety_title"]}</text><text x="48" y="76" class="soft" font-size="14.5">{t["safety_sub"]}</text>'
    return svg(w, h, t["safety_title"], t["safety_title"], o, css)

def main():
    global DOGS
    DOGS = dog(0, 0, 1).replace('class="wag"', "")
    base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets")
    for L, t in TXT.items():
        os.makedirs(os.path.join(base, L), exist_ok=True)
        for name, fn in (("banner", banner), ("flow", flow), ("lifecycle", lifecycle), ("demo", demo), ("architecture", arch), ("safety", safety)):
            with open(os.path.join(base, L, name + ".svg"), "w", encoding="utf-8") as f:
                f.write(fn(L, t))
    print("assets written")

if __name__ == "__main__":
    main()
