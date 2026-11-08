#!/bin/bash
# Duman testi, model harcamaz, gerçek claude oturumu açmaz.
# Depoyu geçici klasöre kopyalar, sahte kartlarla betikleri sınar. kullanım: bash tests/smoke.sh
KOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
OK=0; HATA=0
gecti(){ OK=$((OK+1)); echo "  ok   $1"; }
kaldi(){ HATA=$((HATA+1)); echo "  HATA $1"; [ -z "$2" ] || printf '%s\n' "$2" | sed 's/^/       | /'; }
# kod beklenen ad komut...: çıkış kodu beklenene eşit mi; çıktı SON'da kalır
kod(){ local b="$1" ad="$2"; shift 2; local o c; o="$("$@" 2>&1)"; c=$?
  if [ "$c" = "$b" ]; then gecti "$ad"; else kaldi "$ad (çıkış $c, beklenen $b)" "$o"; fi; SON="$o"; }
icerir(){ if printf '%s\n' "$SON" | grep -qF -- "$2"; then gecti "$1"; else kaldi "$1 (çıktıda yok: $2)" "$SON"; fi; }
icermez(){ if printf '%s\n' "$SON" | grep -qF -- "$2"; then kaldi "$1 (çıktıda olmamalı: $2)" "$SON"; else gecti "$1"; fi; }

export SHEEPDOG_GATE=off   # the stage gates are tested explicitly near the end
export SHEEPDOG_LANG=tr   # existing checks assert the Turkish messages; the English ones are tested at the end
tar -C "$KOK" --exclude=./.git --exclude=./.claude -cf - . | tar -C "$T" -xf -
cd "$T" || exit 1
mkdir -p jobs

echo "bash -n"
for f in ./*.sh tests/*.sh ./sheepdog; do kod 0 "bash -n $f" bash -n "$f"; done

echo "sahte kartlar"
kart(){ mkdir -p "jobs/$1"; printf '# %s\n\nDurum: %s\nTür: kod\nBekliyor: %s\nProje: %s\n' "$1" "$2" "$3" "$T" > "jobs/$1/card.md"; }
kart 001-a bitti yok
kart 002-b hazir 001-a        # beklediği bitti: başlayabilir
kart 003-c hazir 004-d        # beklediği hazir: başlayamaz
kart 004-d hazir yok          # beklemiyor: başlayabilir
kart 005-e taslak yok         # hazir değil: başlayamaz
kart 006-f hazir 099-yok      # beklediği kart yok: başlayamaz
kart 007-g tikandi yok         # tıkanan kart panoda uyarı verir

echo "state.sh"
kod 0 "geçerli durum kabul" ./state.sh jobs/005-e calisiyor
icerir "çıktı kart: durum" "005-e: calisiyor"
if grep -qx 'Durum: calisiyor' jobs/005-e/card.md; then gecti "Durum satırı yazıldı"; else kaldi "Durum satırı yazılmadı" "$(cat jobs/005-e/card.md)"; fi
if grep -q ' 005-e working$' .history 2>/dev/null; then gecti ".history kaydı"; else kaldi ".history kaydı yok"; fi
kod 0 "bütün geçerli durumlar" bash -c 'for d in taslak hazir calisiyor inceleme dogrulama birlesme-bekliyor birlesiyor bitti tikandi; do ./state.sh jobs/005-e "$d" >/dev/null || exit 1; done'
./state.sh jobs/005-e taslak >/dev/null
kod 1 "geçersiz durum reddedilir" ./state.sh jobs/005-e uydurma
icerir "geçersiz durum mesajı" "Geçersiz durum"
if grep -qx 'Durum: taslak' jobs/005-e/card.md; then gecti "geçersiz durum kartı bozmadı"; else kaldi "geçersiz durum kartı değiştirdi" "$(cat jobs/005-e/card.md)"; fi
kod 1 "olmayan kart reddedilir" ./state.sh jobs/yok-kart hazir

echo "board.sh"
kod 0 "tablo" ./board.sh
icerir "başlık" "KART"
for k in 001-a 002-b 003-c 004-d 005-e 006-f 007-g; do icerir "tabloda $k" "$k"; done
icerir "özet satırı" "özet:"
icerir "özette hazir sayısı" "4 hazir"
icerir "tıkanan kart uyarısı" "dikkat: 007-g"
kod 0 "--startable" ./board.sh --startable
B="$SON"
for k in 002-b 004-d; do icerir "başlayabilir: $k" "$k"; done
for k in 001-a 003-c 005-e 006-f 007-g; do icermez "başlayamaz: $k" "$k"; done
if [ "$(printf '%s\n' "$B" | grep -c .)" = 2 ]; then gecti "tam iki kart"; else kaldi "kart sayısı 2 değil" "$B"; fi

echo "launch.sh (claude açılmaz)"
kod 1 "olmayan kart" ./launch.sh jobs/yok-kart isci
icerir "Kart yok mesajı" "Kart yok"
kod 1 "olmayan rol" ./launch.sh jobs/004-d uydurma-rol
icerir "Rol yok mesajı" "Rol yok"

echo "ayarlar ve model seçimi"
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
"$PY" - "$T" > "$T/model-guven.json" <<'JS'
import json,os,sys
print(json.dumps({"projects":{os.path.realpath(sys.argv[1]).replace(os.sep,"/"):{"hasTrustDialogAccepted":True}}}))
JS
# Kuru mod yanlışlıkla claude çağırırsa gerçek oturum açılmasın, test kalsın.
mkdir -p "$T/model-bin"
cat > "$T/model-bin/claude" <<'SAHTE'
#!/bin/bash
echo "HATA: kuru mod claude çağırdı" >&2
exit 99
SAHTE
chmod +x "$T/model-bin/claude"
kuru(){ env PATH="$T/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$T/model-guven.json" SHEEPDOG_DRY=1 ./launch.sh "$@"; }
cp jobs/004-d/card.md "$T/model-kart-once"
cp .history "$T/model-gecmis-once"
for rol in isci reviewer dogrulayici birlestirici; do
  ef=high; [ "$rol" != dogrulayici ] || ef=medium
  kod 0 "$rol varsayılan kuru başlatma" kuru jobs/004-d "$rol"
  icerir "$rol varsayılan model ve efor" "--model sonnet --effort $ef"
  icerir "$rol komut başlangıcı" "claude --bg"
  if [ "$(printf '%s\n' "$SON" | wc -l | tr -d ' ')" = 1 ]; then gecti "$rol tek satır komut"; else kaldi "$rol birden fazla satır" "$SON"; fi
done
kod 0 "kuru mod kartı değiştirmez" cmp jobs/004-d/card.md "$T/model-kart-once"
kod 0 "kuru mod geçmişi değiştirmez" cmp .history "$T/model-gecmis-once"
cp settings.sh "$T/model-ayarlar-once"
cat > settings.sh <<'AYAR'
MODEL_WORKER=haiku; EFFORT_WORKER=low
MODEL_REVIEWER=opus; EFFORT_REVIEWER=medium
MODEL_VERIFIER=haiku; EFFORT_VERIFIER=high
MODEL_MERGER=opus; EFFORT_MERGER=low
AYAR
for rol in isci reviewer dogrulayici birlestirici; do
  case "$rol" in
    isci) model=haiku; ef=low;; reviewer) model=opus; ef=medium;;
    dogrulayici) model=haiku; ef=high;; birlestirici) model=opus; ef=low;;
  esac
  kod 0 "$rol değişen ayarla başlatma" kuru jobs/004-d "$rol"
  icerir "$rol ayar dosyasını kullanır" "--model $model --effort $ef"
done
# Kartın iki alanı da rol ayarını yalnız işçi için geçersiz kılar.
printf '\nModel: opus\nEfor: medium\n' >> jobs/004-d/card.md
kod 0 "kart işçi ayarını geçersiz kılar" kuru jobs/004-d isci
icerir "karttan opus ve medium" "--model opus --effort medium"
cp "$T/model-ayarlar-once" settings.sh
sed "s/^PROFILE=.*/PROFILE=strong/" "$T/model-ayarlar-once" > settings.sh
kod 0 "guclu profil: işçi" kuru jobs/004-d isci
icerir "guclu profil işçiye opus verir" "--model opus"
kod 0 "guclu profil: doğrulayıcı" kuru jobs/004-d dogrulayici
icerir "guclu profil doğrulayıcıya sonnet high verir" "--model sonnet --effort high"
sed "s/^PROFILE=.*/PROFILE=frugal/" "$T/model-ayarlar-once" > settings.sh
kod 0 "ekonomik profil: doğrulayıcı" kuru jobs/004-d dogrulayici
icerir "ekonomik profil doğrulayıcıya haiku verir" "--model haiku"
cp "$T/model-ayarlar-once" settings.sh
for rol in reviewer dogrulayici birlestirici; do
  ef=high; [ "$rol" != dogrulayici ] || ef=medium
  kod 0 "$rol kart modelini yok sayar" kuru jobs/004-d "$rol"
  icerir "$rol kendi model ve eforunu korur" "--model sonnet --effort $ef"
done
cp "$T/model-kart-once" jobs/004-d/card.md
printf '\nModel: opus\n' >> jobs/004-d/card.md
kod 0 "kartta yalnız model" kuru jobs/004-d isci
icerir "eksik kart eforu rol ayarından" "--model opus --effort high"
cp "$T/model-kart-once" jobs/004-d/card.md
printf '\nEfor: low\n' >> jobs/004-d/card.md
kod 0 "kartta yalnız efor" kuru jobs/004-d isci
icerir "eksik kart modeli rol ayarından" "--model sonnet --effort low"
cp "$T/model-kart-once" jobs/004-d/card.md
printf '\nEfor: uydurma\n' >> jobs/004-d/card.md
kod 1 "karttaki geçersiz efor reddedilir" kuru jobs/004-d isci
icerir "geçersiz kart eforu açıklanır" "Geçersiz efor: 'uydurma'"
kod 0 "incelemeci geçersiz kart eforunu da yok sayar" kuru jobs/004-d reviewer
cp "$T/model-kart-once" jobs/004-d/card.md
printf '\nEfor: \n' >> jobs/004-d/card.md
kod 1 "karttaki boş efor reddedilir" kuru jobs/004-d isci
cp "$T/model-kart-once" jobs/004-d/card.md
for rol in isci reviewer dogrulayici birlestirici; do
  cp "$T/model-ayarlar-once" settings.sh
  case "$rol" in isci) alan=EFFORT_WORKER;; reviewer) alan=EFFORT_REVIEWER;; dogrulayici) alan=EFFORT_VERIFIER;; birlestirici) alan=EFFORT_MERGER;; esac
  printf '\n%s=uydurma\n' "$alan" >> settings.sh
  kod 1 "$rol ayarlardaki geçersiz efor reddedilir" kuru jobs/004-d "$rol"
  icerir "$rol geçerli eforlar açıklanır" "beklenen: low, medium, high"
done
# Ayar dosyası bulunmayan eski kurulumlarda da aynı varsayılanlar kullanılır.
rm settings.sh
for rol in isci reviewer dogrulayici birlestirici; do
  ef=high; [ "$rol" != dogrulayici ] || ef=medium
  kod 0 "$rol ayar dosyası olmadan" kuru jobs/004-d "$rol"
  icerir "$rol yerleşik varsayılan" "--model sonnet --effort $ef"
done
mv "$T/model-ayarlar-once" settings.sh
printf '{"projects":{}}\n' > "$T/model-guven.json"
kod 2 "kuru mod güven kontrolünü atlamaz" kuru jobs/004-d isci
icerir "kuru mod güven onayı mesajı" "Güven onayı yok"
kod 0 "bütün model denemeleri kartı korudu" cmp jobs/004-d/card.md "$T/model-kart-once"
kod 0 "bütün model denemeleri geçmişi korudu" cmp .history "$T/model-gecmis-once"

echo "dry-run.sh"
R="$T/depo"; mkdir "$R"
export GIT_AUTHOR_NAME=duman GIT_AUTHOR_EMAIL=duman@example.invalid GIT_COMMITTER_NAME=duman GIT_COMMITTER_EMAIL=duman@example.invalid
g(){ git -C "$R" -c commit.gpgsign=false "$@"; }
if g init -q -b main && echo bir > "$R/a.txt" && echo x > "$R/b.txt" && g add . && g commit -qm ilk \
  && g checkout -q -b temiz && echo iki > "$R/yeni.txt" && g add . && g commit -qm temiz \
  && g checkout -q main && g checkout -q -b cakisan && echo dal > "$R/a.txt" && g commit -qam cakisan \
  && g checkout -q main && echo ana > "$R/a.txt" && g commit -qam ana; then
  kod 0 "temiz birleşme" ./dry-run.sh "$R" temiz main
  icerir "TEMIZ der" "TEMIZ"
  kod 1 "çakışma" ./dry-run.sh "$R" cakisan main
  icerir "CAKISMA der" "CAKISMA"
  icerir "çakışan dosya" "a.txt"
  kod 2 "olmayan dal" ./dry-run.sh "$R" yok-dal main
  if [ "$(g rev-parse main)" = "$(g rev-parse HEAD)" ] && [ -z "$(g status --porcelain)" ]; then gecti "ana dal değişmedi"; else kaldi "ana dal/çalışma ağacı değişti"; fi
else
  kaldi "geçici git deposu kurulamadı (git sürümü: $(git --version))"
fi

echo "doctor.sh (sahte claude ile)"
mkdir -p "$T/sahte-bin"
cat > "$T/sahte-bin/claude" <<'SAHTE'
#!/bin/bash
case "$1" in
  --version) echo "${SAHTE_SURUM:-2.1.293} (Claude Code)";;
  --help) printf -- '  --bg  arka planda başlat\n  --permission-mode <mode>  izin modu\n    (choices: "default", "auto")\n';;
  agents) echo "Usage: claude agents [options]";;
esac
SAHTE
chmod +x "$T/sahte-bin/claude"
kod 0 "yeterli sürüm" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.2.0 ./doctor.sh
icerir "sürüm kabul" "claude sürümü 2.2.0"
icerir "--bg görülür" "claude --bg destekleniyor"
kod 1 "eski sürüm reddedilir" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.1.200 ./doctor.sh
icerir "eski sürüm mesajı" "en az 2.1.293"
kod 0 "eşit sürüm kabul" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.1.293 ./doctor.sh

echo "trust.py"
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
G="$T/guven"; mkdir -p "$G/onayli-depo" "$G/onaysiz-depo" "$G/ust/alt" "$T/baska"
git -C "$G/onayli-depo" init -q; git -C "$G/onaysiz-depo" init -q
"$PY" - "$G" "$G/onayli-depo" > "$T/claude.json" <<'JS'
import json,os,sys
print(json.dumps({"projects":{os.path.realpath(a).replace(os.sep,"/"):{"hasTrustDialogAccepted":True} for a in sys.argv[1:]}}))
JS
export SHEEPDOG_CLAUDE_JSON="$T/claude.json"
kod 0 "onaylı git deposu" "$PY" trust.py "$G/onayli-depo"
kod 1 "üstü onaylı ama kendisi onaysız git deposu" "$PY" trust.py "$G/onaysiz-depo"
kod 0 "git dışı klasör üstten onay alır" "$PY" trust.py "$G/ust/alt"
kod 1 "hiçbir üstü onaylı olmayan klasör" "$PY" trust.py "$T/baska"
unset SHEEPDOG_CLAUDE_JSON

echo "trial/setup.sh"
kod 0 "deneme kurucusu bash sözdizimi" bash -n trial/setup.sh
# Önce dolu hedef: henüz kartlar yok, red nedeni kart çakışması olamaz.
DOLU="$T/dolu hedef"; mkdir "$DOLU"
printf 'korunacak\n' > "$DOLU/.gizli"
kod 1 "dolu hedef reddedilir" bash trial/setup.sh "$DOLU"
icerir "dolu hedef açıklaması" "Hedef boş bir klasör olmalı"
if [ "$(cat "$DOLU/.gizli")" = korunacak ] && [ "$(ls -A "$DOLU" | wc -l | tr -d ' ')" = 1 ] \
  && [ ! -e jobs/901-iade-hatasi ] && [ ! -e jobs/902-gecikme-listesi ] && [ ! -e jobs/903-kullanim-notu ]; then
  gecti "dolu hedef ve kartlar değişmedi"
else kaldi "dolu hedef reddinde dosyalar değişti"; fi

# Ayrı global config, kullanıcının ayarını okumadan/yazmadan kimlik yedeğini sınar.
DENEME_GIT_CONFIG="$T/deneme-global-config"
printf '[init]\n\tdefaultBranch = baska\n' > "$DENEME_GIT_CONFIG"
cp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
D="$T/kitaplık denemesi"
kod 0 "geçici hedefe kurulum" env GIT_CONFIG_GLOBAL="$DENEME_GIT_CONFIG" GIT_CONFIG_NOSYSTEM=1 bash trial/setup.sh "$D"
icerir "kurulum sonraki adımları gösterir" "claude --agent sheepdog-tr --name sheepdog --permission-mode auto"
icerir "güven onayı adımı" "güven onayını"
icerir "başlatma isteği" "hazır kartları başlat"
icerir "canlı pano komutu" "./board.sh --watch"
kod 0 "hedefte git deposu" git -C "$D" rev-parse --is-inside-work-tree
icerir "git deposu doğrulaması" "true"
kod 0 "hedefte ilk commit" git -C "$D" rev-parse --verify HEAD
DENEME_ILK="$SON"
kod 0 "hedef main dalında" git -C "$D" branch --show-current
icerir "ana dal adı" "main"
kod 0 "yalnız yerel kimlik adı" git -C "$D" config --local --get user.name
icerir "yedek ad" "trial"
kod 0 "yalnız yerel kimlik e-postası" git -C "$D" config --local --get user.email
icerir "yedek e-posta" "trial@example.invalid"
kod 0 "global ayar aynı kaldı" cmp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
kod 0 "projenin başlangıç testleri" bash -c 'cd "$1" && PYTHONUTF8=1 "$2" -m unittest' _ "$D" "$PY"
icerir "başlangıçta 8 test" "Ran 8 tests"
icerir "başlangıç test sonucu" "OK"
kod 0 "erken iade hatasını yeniden üret" bash -c 'cd "$1" && PYTHONUTF8=1 "$2" -m kitaplik gecikme --son-tarih 2026-01-15 --iade-tarihi 2026-01-01' _ "$D" "$PY"
icerir "bilerek bırakılan negatif gecikme" "Gecikme: -14 gün"
DENEME_MUTLAK="$(PYTHONUTF8=1 "$PY" -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_posix())' "$D")"
for ad in 901-iade-hatasi 902-gecikme-listesi 903-kullanim-notu; do
  if [ -f "jobs/$ad/card.md" ] && grep -qx 'Durum: hazir' "jobs/$ad/card.md" \
    && grep -qxF "Proje: $DENEME_MUTLAK" "jobs/$ad/card.md"; then
    gecti "hazır kart ve mutlak proje yolu: $ad"
  else kaldi "kart veya proje yolu yanlış: $ad" "beklenen: Proje: $DENEME_MUTLAK | kartta: $(grep -m1 '^Proje:' "jobs/$ad/card.md" 2>/dev/null) | $(grep -m1 '^Durum:' "jobs/$ad/card.md" 2>/dev/null)"; fi
done
if grep -F '{{PROJE}}' jobs/90*/card.md; then kaldi "kartlarda yer tutucu kaldı"; else gecti "kartlarda yer tutucu yok"; fi
kod 0 "deneme kartları başlatılabilirlik" ./board.sh --startable
icerir "901 başlayabilir" "901-iade-hatasi"
icerir "902 başlayabilir" "902-gecikme-listesi"
icermez "903 bağımlı, başlayamaz" "903-kullanim-notu"
cp jobs/901-iade-hatasi/card.md "$T/deneme-kart-once"
kod 1 "aynı hedefe ikinci kurulum reddedilir" bash trial/setup.sh "$D"
kod 1 "aynı adlı kart yeni hedefi engeller" bash trial/setup.sh "$T/kurulmamali"
icerir "kart çakışması açıklaması" "Kart zaten var"
if [ ! -e "$T/kurulmamali" ]; then gecti "kart çakışmasında hedef oluşturulmadı"; else kaldi "çakışmada hedefe yazıldı"; fi
kod 0 "mevcut kartın üzerine yazılmadı" cmp jobs/901-iade-hatasi/card.md "$T/deneme-kart-once"
if [ "$(git -C "$D" rev-parse HEAD)" = "$DENEME_ILK" ] && [ -z "$(git -C "$D" status --porcelain)" ]; then
  gecti "tekrar kurulum projeyi değiştirmedi"
else kaldi "tekrar kurulum projeyi değiştirdi"; fi

# Boş ama önceden var olan hedef ve mevcut global kimlik de desteklenir.
E="$T/ikinci-merkez"; mkdir "$E" "$T/bos-hedef"
cp -R trial "$E/trial"
git config --file "$DENEME_GIT_CONFIG" user.name "Ornek Kullanici"
git config --file "$DENEME_GIT_CONFIG" user.email "ornek@example.invalid"
cp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
kod 0 "mevcut boş hedefe kurulum" env GIT_CONFIG_GLOBAL="$DENEME_GIT_CONFIG" GIT_CONFIG_NOSYSTEM=1 bash "$E/trial/setup.sh" "$T/bos-hedef"
kod 1 "global kimlik varsa yerel ad yazılmaz" git -C "$T/bos-hedef" config --local --get user.name
kod 1 "global kimlik varsa yerel e-posta yazılmaz" git -C "$T/bos-hedef" config --local --get user.email
kod 0 "mevcut global kimlik değişmedi" cmp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"

echo "main-branch.sh, rounds.sh, çoklu bağımlılık, master"
M="$T/master-proje"; mkdir -p "$M"; g2(){ git -C "$M" -c user.name=t -c user.email=t@x "$@"; }
g2 init -q -b master && echo a > "$M/a" && g2 add . && g2 commit -qm ilk && g2 checkout -q -b dal && echo b > "$M/b" && g2 add . && g2 commit -qm dal && g2 checkout -q master
kod 0 "main-branch.sh master bulur" ./main-branch.sh "$M"
icerir "ana dal adı master" "master"
kod 0 "hazırlık hedefi otomatik (master)" ./dry-run.sh "$M" dal
icerir "TEMIZ" "TEMIZ"
kod 1 "main-branch.sh git olmayan klasörde hata" ./main-branch.sh "$T/yok-klasor"
printf '1 007-g calisiyor\n2 007-g inceleme\n3 007-g calisiyor\n' > .history
kod 0 "rounds.sh" ./rounds.sh jobs/007-g
icerir "iki tur" "2"
kart 010-x hazir "001-a,004-d"; kart 011-y hazir "001-a,001-a"
kod 0 "çoklu bağımlılık" ./board.sh --startable
icermez "bitmeyen bağımlılık başlamaz" "010-x"
icerir "tüm bağımlılıklar bitmiş başlar" "011-y"
kart 012-z hazir "~/yok"; sed 's#^Proje: .*#Proje: ~/olmayan-klasor-xyz#' jobs/012-z/card.md > jobs/012-z/card.tmp && mv jobs/012-z/card.tmp jobs/012-z/card.md
kod 1 "tilde yolu açılır, klasör yoksa hata" ./launch.sh jobs/012-z isci
icerir "açılmış yol" "$HOME/olmayan-klasor-xyz"

echo "sheepdog (front door)"

kod 0 "help" ./sheepdog help
icerir "help lists policy" "policy"
kod 2 "bilinmeyen komut" ./sheepdog nope
kod 0 "policy varsayılan auto" ./sheepdog policy
icerir "auto" "auto"
kod 0 "policy ask" ./sheepdog policy ask
kod 0 "policy kalıcı" ./sheepdog policy
icerir "ask kalıcı" "ask"
kod 2 "geçersiz policy" ./sheepdog policy bogus
./sheepdog policy auto >/dev/null
kod 0 "new kart" ./sheepdog new demo-is --project "$T" --type icerik --waits 001-a
icerir "yeni kart yolu" "demo-is/card.md"
KN="$(ls -d jobs/[0-9][0-9][0-9]-demo-is)"; grep -q '^Tür: icerik' "$KN/card.md" && grep -q '^Bekliyor: 001-a' "$KN/card.md" && grep -q '^Durum: taslak' "$KN/card.md" && gecti "yeni kart alanları" || kaldi "yeni kart alanları"
kod 2 "new geçersiz slug" ./sheepdog new "Bad Slug" --project "$T"
kod 2 "new proje zorunlu" ./sheepdog new x-y
kod 0 "rounds" ./sheepdog rounds 007-g
kod 0 "timeline" ./sheepdog timeline
icerir "timeline kart" "007-g"
kod 0 "ready" ./sheepdog ready
kod 0 "board" ./sheepdog board

echo "English (SHEEPDOG_LANG=en)"
"$PY" - "$T" > "$T/en-guven.json" <<'JS'
import json,os,sys
print(json.dumps({"projects":{os.path.realpath(sys.argv[1]).replace(os.sep,"/"):{"hasTrustDialogAccepted":True}}}))
JS
export SHEEPDOG_LANG=en
mkdir -p jobs/020-en; printf '# 020: en\n\nStatus: ready\nType: code\nWaits-for: none\nProject: %s\n' "$T" > jobs/020-en/card.md
mkdir -p jobs/021-en; printf '# 021: en\n\nStatus: ready\nType: content\nWaits-for: 020-en, \nProject: %s\n' "$T" > jobs/021-en/card.md
kod 0 "ready lists English card" ./sheepdog ready
icerir "English card startable" "020-en"
kod 0 "set accepts English state" ./state.sh jobs/020-en working
icerir "output in English" "020-en: working"
grep -qx 'Status: working' jobs/020-en/card.md && gecti "Status line keeps its language" || kaldi "Status line keeps its language"
grep -q ' 020-en working$' .history && gecti "log uses canonical state" || kaldi "log uses canonical state"
kod 0 "rounds counts English-set work" ./rounds.sh jobs/020-en
icerir "one round" "1"
kod 0 "board in English" ./sheepdog board
icerir "English header" "STATE"
icerir "English state shown" "working"
kod 1 "invalid state English message" ./state.sh jobs/020-en bogus
icerir "invalid state text" "Invalid state"
kod 0 "mixed: Turkish value on English card" ./state.sh jobs/020-en inceleme
grep -qx 'Status: review' jobs/020-en/card.md && gecti "English card stores English value" || kaldi "English card stores English value"
kod 0 "new card in English" ./sheepdog new en-card --project "$T" --type code
icerir "English card path" "en-card/card.md"
KE="$(ls -d jobs/[0-9][0-9][0-9]-en-card)"; grep -q '^Type: code' "$KE/card.md" && grep -q '^Status: draft' "$KE/card.md" && grep -q '^## Definition of done' "$KE/card.md" && gecti "English template" || kaldi "English template"
kod 0 "lang shows en" ./sheepdog lang
icerir "lang en" "en"
kod 0 "role alias worker" env ROL2=worker bash -c 'env PATH="$0/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$0/en-guven.json" SHEEPDOG_DRY=1 ./launch.sh jobs/004-d worker' "$T"
icerir "English role prompt used" "roles/en/worker.md"
kod 0 "Turkish role prompt when tr" env SHEEPDOG_LANG=tr PATH="$T/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$T/en-guven.json" SHEEPDOG_DRY=1 ./launch.sh jobs/004-d isci
icerir "Turkish role prompt" "roles/tr/worker.md"
kod 0 "doctor in English" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.2.0 ./sheepdog doctor
icerir "doctor English" "required checks"
kod 0 "trial English default" env GIT_CONFIG_GLOBAL="$DENEME_GIT_CONFIG" GIT_CONFIG_NOSYSTEM=1 bash "$E/trial/setup.sh" "$T/en-deneme"
icerir "trial English output" "Three ready cards: 901-early-return-bug"
kod 0 "English trial project tests pass" bash -c "cd '$T/en-deneme' && python3 -m unittest 2>&1 | tail -1 | grep -q OK || python -m unittest 2>&1 | tail -1 | grep -q OK"
kod 0 "English trial shows the planted bug" bash -c "cd '$T/en-deneme' && (python3 -m library lateness --due-date 2026-01-15 --return-date 2026-01-01 || python -m library lateness --due-date 2026-01-15 --return-date 2026-01-01) | grep -q 'Late: -14 days'"
grep -q '^Status: ready' "$T/en-deneme/../ikinci-merkez/jobs/901-early-return-bug/card.md" && gecti "English trial card ready" || kaldi "English trial card ready"
kod 0 "ana-dal English error text" bash -c './main-branch.sh "$0/yok-klasor" 2>&1 | grep -q "Main branch not found"; true' "$T"

echo "regressions from the independent review"
# main-branch.sh must not mistake a checked-out feature branch for the main branch
FR="$T/feat-repo"; mkdir -p "$FR"; gf(){ git -C "$FR" -c user.name=t -c user.email=t@x "$@"; }
gf init -q -b main && echo a > "$FR/a" && gf add . && gf commit -qm i && gf checkout -q -b feat/x
kod 0 "main-branch ignores a checked-out feature branch" ./main-branch.sh "$FR"
icerir "reports main" "main"
icermez "not the feature branch" "feat"
kod 0 "dry-run targets main, not the feature branch" ./dry-run.sh "$FR" feat/x
icerir "dry run main -> feature" "feat/x -> main"
# state.sh changes only the first Status/Durum line and keeps CRLF
mkdir -p jobs/030-body; printf '# 030\r\n\r\nStatus: Ready\r\nType: code\r\nProject: %s\r\n\r\n```\r\nStatus: example\r\n```\r\n' "$T" > jobs/030-body/card.md
kod 0 "state.sh accepts a capitalised state in the card" ./board.sh --startable
icerir "capitalised Ready is startable" "030-body"
kod 0 "state.sh on a CRLF card" ./state.sh jobs/030-body working
grep -c '^Status: ' jobs/030-body/card.md | grep -qx 2 && grep -q '^Status: example' jobs/030-body/card.md && grep -q '^Status: working' jobs/030-body/card.md && gecti "only the first Status line changed" || kaldi "only the first Status line changed"
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) gecti "CRLF kept (skipped on Windows)";; *) head -3 jobs/030-body/card.md | grep -q "$(printf 'working\r')" && gecti "CRLF kept" || kaldi "CRLF kept";; esac
# launch.sh hardening
mkdir -p jobs/031-dash; printf '# 031\n\nStatus: ready\nType: code\nModel: --dangerously-skip-permissions\nProject: %s\n' "$T" > jobs/031-dash/card.md
kod 1 "launch rejects a model that starts with a dash" env PATH="$T/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$T/en-guven.json" SHEEPDOG_DRY=1 ./launch.sh jobs/031-dash worker
icerir "invalid model message" "Invalid model/effort"
kod 0 "reviewer Turkish alias incelemeci" env PATH="$T/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$T/en-guven.json" SHEEPDOG_DRY=1 ./launch.sh jobs/004-d incelemeci
icerir "alias resolves to the reviewer prompt" "roles/en/reviewer.md"
mkdir -p jobs/032-done; printf '# 032\n\nStatus: done\nType: code\nProject: %s\n' "$T" > jobs/032-done/card.md
kod 1 "launch refuses a worker for a done card" env PATH="$T/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$T/en-guven.json" SHEEPDOG_DRY=1 ./launch.sh jobs/032-done worker
icerir "done card message" "already done"
# watchdog.sh survives an unexpected JSON shape and reports after three failures
mkdir -p "$T/wd-bin"; printf '#!/bin/bash\necho {\\"error\\":\\"x\\"}\n' > "$T/wd-bin/claude"; chmod +x "$T/wd-bin/claude"
kod 0 "watchdog reports an unlistable session list (no traceback)" env PATH="$T/wd-bin:$PATH" ./watchdog.sh 0 20
icerir "watchdog report" "could not list sessions"
icermez "no Python traceback" "Traceback"

echo "seal.sh (tamper evidence)"
mkdir -p jobs/040-seal; printf '# 040\n\nStatus: working\nType: code\nProject: %s\n' "$T" > jobs/040-seal/card.md
kod 0 "pre: nothing written yet" ./seal.sh pre jobs/040-seal reviewer
kod 1 "done: file missing" ./seal.sh done jobs/040-seal reviewer
echo "RESULT: PASSED" > jobs/040-seal/review.md
kod 1 "pre: an unsealed verdict already exists (forged by another role)" ./seal.sh pre jobs/040-seal reviewer
icerir "TAMPER reported" "TAMPER"
rm jobs/040-seal/review.md; echo "everything done" > jobs/040-seal/result.md
kod 0 "worker seals its result" ./seal.sh done jobs/040-seal worker
kod 0 "check is clean" ./seal.sh check jobs/040-seal
echo "edited later" >> jobs/040-seal/result.md
kod 1 "check detects an edit after sealing" ./seal.sh check jobs/040-seal
icerir "edit reported" "changed after it was sealed"
kod 1 "pre: edited sealed file is flagged" ./seal.sh pre jobs/040-seal worker
echo "everything done" > jobs/040-seal/result.md
kod 0 "restored content passes again" ./seal.sh check jobs/040-seal
kod 0 "pre: an earlier sealed round is fine" ./seal.sh pre jobs/040-seal worker
kod 2 "usage error" ./seal.sh bogus jobs/040-seal
kod 0 "front door seal" ./sheepdog seal check jobs/040-seal
rm -f jobs/040-seal/result.md
kod 1 "check detects a deleted sealed file" ./seal.sh check jobs/040-seal

echo "stage gates (state.sh cannot skip review, verification or the merge)"
G="env SHEEPDOG_GATE=on"
mkdir -p jobs/050-gate; printf '# 050\n\nStatus: working\nType: code\nProject: %s\n' "$T" > jobs/050-gate/card.md
kod 1 "gate: review needs a sealed result" $G ./state.sh jobs/050-gate review
icerir "gate message" "STAGE SKIPPED"
echo "done" > jobs/050-gate/result.md; ./seal.sh done jobs/050-gate worker >/dev/null
kod 0 "gate: review allowed after the worker's result is sealed" $G ./state.sh jobs/050-gate review
kod 1 "gate: verify needs a reviewer verdict" $G ./state.sh jobs/050-gate verify
printf 'looks bad\nRESULT: FAILED\n' > jobs/050-gate/review.md; ./seal.sh done jobs/050-gate reviewer >/dev/null
kod 1 "gate: verify refused after a failed review" $G ./state.sh jobs/050-gate verify
icerir "NOT PASSED" "NOT PASSED"
printf 'fixed\nRESULT: PASSED\n' > jobs/050-gate/review.md; ./seal.sh done jobs/050-gate reviewer >/dev/null
kod 0 "gate: verify allowed after a passed, sealed review" $G ./state.sh jobs/050-gate verify
kod 1 "gate: merge-queue needs a verifier verdict" $G ./state.sh jobs/050-gate merge-queue
kod 1 "gate: done is refused for a code card with no merge" $G ./state.sh jobs/050-gate done
printf 'ok\nSONUÇ: GEÇTİ\n' > jobs/050-gate/verification.md; ./seal.sh done jobs/050-gate verifier >/dev/null
kod 0 "gate: merge-queue allowed (Turkish verdict marker accepted)" $G ./state.sh jobs/050-gate merge-queue
kod 0 "gate: merging allowed" $G ./state.sh jobs/050-gate merging
kod 1 "gate: done needs the merger's verdict" $G ./state.sh jobs/050-gate done
printf 'merged\nRESULT: PASSED\n' > jobs/050-gate/merge.md; ./seal.sh done jobs/050-gate merger >/dev/null
kod 0 "gate: done allowed after the merger's sealed verdict" $G ./state.sh jobs/050-gate done
echo "tampered" >> jobs/050-gate/review.md
kod 1 "gate: an edited verdict blocks the next transition" $G ./state.sh jobs/050-gate merging
icerir "tamper reported" "TAMPER"
kod 0 "gate: going back to working is never gated" $G ./state.sh jobs/050-gate working
kod 0 "gate: a human can bypass with SHEEPDOG_GATE=off" env SHEEPDOG_GATE=off ./state.sh jobs/050-gate done
mkdir -p jobs/051-content; printf '# 051\n\nStatus: review\nType: content\nProject: %s\n' "$T" > jobs/051-content/card.md
kod 1 "gate: content card cannot finish without review" $G ./state.sh jobs/051-content done
printf 'RESULT: PASSED\n' > jobs/051-content/review.md; ./seal.sh done jobs/051-content reviewer >/dev/null
kod 0 "gate: content card finishes after a passed review (no merge needed)" $G ./state.sh jobs/051-content done

echo "merge approval (policy ask)"
./sheepdog policy ask >/dev/null
mkdir -p jobs/060-appr; printf '# 060\n\nStatus: merge-queue\nType: code\nProject: %s\n' "$T" > jobs/060-appr/card.md
kod 1 "state merging refused while policy is ask and the card is not approved" ./state.sh jobs/060-appr merging
icerir "approval message" "APPROVAL NEEDED"
kod 1 "merger launch refused before approval" env PATH="$T/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$T/en-guven.json" SHEEPDOG_DRY=1 ./launch.sh jobs/060-appr merger
icerir "launch approval message" "APPROVAL NEEDED"
kod 0 "approve records the approval" ./sheepdog approve 060-appr
kod 0 "state merging allowed after approval" ./state.sh jobs/060-appr merging
kod 0 "merger launch allowed after approval" env PATH="$T/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$T/en-guven.json" SHEEPDOG_DRY=1 ./launch.sh jobs/060-appr merger
kod 1 "approve needs a real card" ./sheepdog approve 999-nope
mkdir -p jobs/061-other; printf '# 061\n\nStatus: merge-queue\nType: code\nProject: %s\n' "$T" > jobs/061-other/card.md
kod 1 "approval is per card" ./state.sh jobs/061-other merging
./sheepdog policy auto >/dev/null
kod 0 "policy auto needs no approval" ./state.sh jobs/061-other merging

echo
echo "result: $OK passed, $HATA failed"
[ "$HATA" = 0 ]
