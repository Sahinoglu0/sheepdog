#!/bin/bash
# Duman testi, model harcamaz, gerçek claude oturumu açmaz.
# Depoyu geçici klasöre kopyalar, sahte kartlarla betikleri sınar. kullanım: bash testler/duman.sh
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

tar -C "$KOK" --exclude=./.git --exclude=./.claude -cf - . | tar -C "$T" -xf -
cd "$T" || exit 1
mkdir -p isler

echo "bash -n"
for f in ./*.sh testler/*.sh; do kod 0 "bash -n $f" bash -n "$f"; done

echo "sahte kartlar"
kart(){ mkdir -p "isler/$1"; printf '# %s\n\nDurum: %s\nTür: kod\nBekliyor: %s\nProje: %s\n' "$1" "$2" "$3" "$T" > "isler/$1/kart.md"; }
kart 001-a bitti yok
kart 002-b hazir 001-a        # beklediği bitti: başlayabilir
kart 003-c hazir 004-d        # beklediği hazir: başlayamaz
kart 004-d hazir yok          # beklemiyor: başlayabilir
kart 005-e taslak yok         # hazir değil: başlayamaz
kart 006-f hazir 099-yok      # beklediği kart yok: başlayamaz
kart 007-g tikandi yok         # tıkanan kart panoda uyarı verir

echo "durum.sh"
kod 0 "geçerli durum kabul" ./durum.sh isler/005-e calisiyor
icerir "çıktı kart: durum" "005-e: calisiyor"
if grep -qx 'Durum: calisiyor' isler/005-e/kart.md; then gecti "Durum satırı yazıldı"; else kaldi "Durum satırı yazılmadı" "$(cat isler/005-e/kart.md)"; fi
if grep -q ' 005-e calisiyor$' .gecmis 2>/dev/null; then gecti ".gecmis kaydı"; else kaldi ".gecmis kaydı yok"; fi
kod 0 "bütün geçerli durumlar" bash -c 'for d in taslak hazir calisiyor inceleme dogrulama birlesme-bekliyor birlesiyor bitti tikandi; do ./durum.sh isler/005-e "$d" >/dev/null || exit 1; done'
./durum.sh isler/005-e taslak >/dev/null
kod 1 "geçersiz durum reddedilir" ./durum.sh isler/005-e uydurma
icerir "geçersiz durum mesajı" "Geçersiz durum"
if grep -qx 'Durum: taslak' isler/005-e/kart.md; then gecti "geçersiz durum kartı bozmadı"; else kaldi "geçersiz durum kartı değiştirdi" "$(cat isler/005-e/kart.md)"; fi
kod 1 "olmayan kart reddedilir" ./durum.sh isler/yok-kart hazir

echo "pano.sh"
kod 0 "tablo" ./pano.sh
icerir "başlık" "KART"
for k in 001-a 002-b 003-c 004-d 005-e 006-f 007-g; do icerir "tabloda $k" "$k"; done
icerir "özet satırı" "özet:"
icerir "özette hazir sayısı" "4 hazir"
icerir "tıkanan kart uyarısı" "dikkat: 007-g"
kod 0 "--baslayabilir" ./pano.sh --baslayabilir
B="$SON"
for k in 002-b 004-d; do icerir "başlayabilir: $k" "$k"; done
for k in 001-a 003-c 005-e 006-f 007-g; do icermez "başlayamaz: $k" "$k"; done
if [ "$(printf '%s\n' "$B" | grep -c .)" = 2 ]; then gecti "tam iki kart"; else kaldi "kart sayısı 2 değil" "$B"; fi

echo "baslat.sh (claude açılmaz)"
kod 1 "olmayan kart" ./baslat.sh isler/yok-kart isci
icerir "Kart yok mesajı" "Kart yok"
kod 1 "olmayan rol" ./baslat.sh isler/004-d uydurma-rol
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
kuru(){ env PATH="$T/model-bin:$PATH" SHEEPDOG_CLAUDE_JSON="$T/model-guven.json" SHEEPDOG_KURU=1 ./baslat.sh "$@"; }
cp isler/004-d/kart.md "$T/model-kart-once"
cp .gecmis "$T/model-gecmis-once"
for rol in isci reviewer dogrulayici birlestirici; do
  ef=high; [ "$rol" != dogrulayici ] || ef=medium
  kod 0 "$rol varsayılan kuru başlatma" kuru isler/004-d "$rol"
  icerir "$rol varsayılan model ve efor" "--model sonnet --effort $ef"
  icerir "$rol komut başlangıcı" "claude --bg"
  if [ "$(printf '%s\n' "$SON" | wc -l | tr -d ' ')" = 1 ]; then gecti "$rol tek satır komut"; else kaldi "$rol birden fazla satır" "$SON"; fi
done
kod 0 "kuru mod kartı değiştirmez" cmp isler/004-d/kart.md "$T/model-kart-once"
kod 0 "kuru mod geçmişi değiştirmez" cmp .gecmis "$T/model-gecmis-once"
cp ayarlar.sh "$T/model-ayarlar-once"
cat > ayarlar.sh <<'AYAR'
MODEL_ISCI=haiku; EFOR_ISCI=low
MODEL_INCELEMECI=opus; EFOR_INCELEMECI=medium
MODEL_DOGRULAYICI=haiku; EFOR_DOGRULAYICI=high
MODEL_BIRLESTIRICI=opus; EFOR_BIRLESTIRICI=low
AYAR
for rol in isci reviewer dogrulayici birlestirici; do
  case "$rol" in
    isci) model=haiku; ef=low;; reviewer) model=opus; ef=medium;;
    dogrulayici) model=haiku; ef=high;; birlestirici) model=opus; ef=low;;
  esac
  kod 0 "$rol değişen ayarla başlatma" kuru isler/004-d "$rol"
  icerir "$rol ayar dosyasını kullanır" "--model $model --effort $ef"
done
# Kartın iki alanı da rol ayarını yalnız işçi için geçersiz kılar.
printf '\nModel: opus\nEfor: medium\n' >> isler/004-d/kart.md
kod 0 "kart işçi ayarını geçersiz kılar" kuru isler/004-d isci
icerir "karttan opus ve medium" "--model opus --effort medium"
cp "$T/model-ayarlar-once" ayarlar.sh
sed "s/^PROFIL=.*/PROFIL=guclu/" "$T/model-ayarlar-once" > ayarlar.sh
kod 0 "guclu profil: işçi" kuru isler/004-d isci
icerir "guclu profil işçiye opus verir" "--model opus"
kod 0 "guclu profil: doğrulayıcı" kuru isler/004-d dogrulayici
icerir "guclu profil doğrulayıcıya sonnet high verir" "--model sonnet --effort high"
sed "s/^PROFIL=.*/PROFIL=ekonomik/" "$T/model-ayarlar-once" > ayarlar.sh
kod 0 "ekonomik profil: doğrulayıcı" kuru isler/004-d dogrulayici
icerir "ekonomik profil doğrulayıcıya haiku verir" "--model haiku"
cp "$T/model-ayarlar-once" ayarlar.sh
for rol in reviewer dogrulayici birlestirici; do
  ef=high; [ "$rol" != dogrulayici ] || ef=medium
  kod 0 "$rol kart modelini yok sayar" kuru isler/004-d "$rol"
  icerir "$rol kendi model ve eforunu korur" "--model sonnet --effort $ef"
done
cp "$T/model-kart-once" isler/004-d/kart.md
printf '\nModel: opus\n' >> isler/004-d/kart.md
kod 0 "kartta yalnız model" kuru isler/004-d isci
icerir "eksik kart eforu rol ayarından" "--model opus --effort high"
cp "$T/model-kart-once" isler/004-d/kart.md
printf '\nEfor: low\n' >> isler/004-d/kart.md
kod 0 "kartta yalnız efor" kuru isler/004-d isci
icerir "eksik kart modeli rol ayarından" "--model sonnet --effort low"
cp "$T/model-kart-once" isler/004-d/kart.md
printf '\nEfor: uydurma\n' >> isler/004-d/kart.md
kod 1 "karttaki geçersiz efor reddedilir" kuru isler/004-d isci
icerir "geçersiz kart eforu açıklanır" "Geçersiz efor: 'uydurma'"
kod 0 "incelemeci geçersiz kart eforunu da yok sayar" kuru isler/004-d reviewer
cp "$T/model-kart-once" isler/004-d/kart.md
printf '\nEfor: \n' >> isler/004-d/kart.md
kod 1 "karttaki boş efor reddedilir" kuru isler/004-d isci
cp "$T/model-kart-once" isler/004-d/kart.md
for rol in isci reviewer dogrulayici birlestirici; do
  cp "$T/model-ayarlar-once" ayarlar.sh
  case "$rol" in isci) alan=EFOR_ISCI;; reviewer) alan=EFOR_INCELEMECI;; dogrulayici) alan=EFOR_DOGRULAYICI;; birlestirici) alan=EFOR_BIRLESTIRICI;; esac
  printf '\n%s=uydurma\n' "$alan" >> ayarlar.sh
  kod 1 "$rol ayarlardaki geçersiz efor reddedilir" kuru isler/004-d "$rol"
  icerir "$rol geçerli eforlar açıklanır" "beklenen: low, medium, high"
done
# Ayar dosyası bulunmayan eski kurulumlarda da aynı varsayılanlar kullanılır.
rm ayarlar.sh
for rol in isci reviewer dogrulayici birlestirici; do
  ef=high; [ "$rol" != dogrulayici ] || ef=medium
  kod 0 "$rol ayar dosyası olmadan" kuru isler/004-d "$rol"
  icerir "$rol yerleşik varsayılan" "--model sonnet --effort $ef"
done
mv "$T/model-ayarlar-once" ayarlar.sh
printf '{"projects":{}}\n' > "$T/model-guven.json"
kod 2 "kuru mod güven kontrolünü atlamaz" kuru isler/004-d isci
icerir "kuru mod güven onayı mesajı" "Güven onayı yok"
kod 0 "bütün model denemeleri kartı korudu" cmp isler/004-d/kart.md "$T/model-kart-once"
kod 0 "bütün model denemeleri geçmişi korudu" cmp .gecmis "$T/model-gecmis-once"

echo "birlestirme-hazirla.sh"
R="$T/depo"; mkdir "$R"
export GIT_AUTHOR_NAME=duman GIT_AUTHOR_EMAIL=duman@example.invalid GIT_COMMITTER_NAME=duman GIT_COMMITTER_EMAIL=duman@example.invalid
g(){ git -C "$R" -c commit.gpgsign=false "$@"; }
if g init -q -b main && echo bir > "$R/a.txt" && echo x > "$R/b.txt" && g add . && g commit -qm ilk \
  && g checkout -q -b temiz && echo iki > "$R/yeni.txt" && g add . && g commit -qm temiz \
  && g checkout -q main && g checkout -q -b cakisan && echo dal > "$R/a.txt" && g commit -qam cakisan \
  && g checkout -q main && echo ana > "$R/a.txt" && g commit -qam ana; then
  kod 0 "temiz birleşme" ./birlestirme-hazirla.sh "$R" temiz main
  icerir "TEMIZ der" "TEMIZ"
  kod 1 "çakışma" ./birlestirme-hazirla.sh "$R" cakisan main
  icerir "CAKISMA der" "CAKISMA"
  icerir "çakışan dosya" "a.txt"
  kod 2 "olmayan dal" ./birlestirme-hazirla.sh "$R" yok-dal main
  if [ "$(g rev-parse main)" = "$(g rev-parse HEAD)" ] && [ -z "$(g status --porcelain)" ]; then gecti "ana dal değişmedi"; else kaldi "ana dal/çalışma ağacı değişti"; fi
else
  kaldi "geçici git deposu kurulamadı (git sürümü: $(git --version))"
fi

echo "kontrol.sh (sahte claude ile)"
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
kod 0 "yeterli sürüm" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.2.0 ./kontrol.sh
icerir "sürüm kabul" "claude sürümü 2.2.0"
icerir "--bg görülür" "claude --bg destekleniyor"
kod 1 "eski sürüm reddedilir" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.1.200 ./kontrol.sh
icerir "eski sürüm mesajı" "en az 2.1.293"
kod 0 "eşit sürüm kabul" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.1.293 ./kontrol.sh

echo "guven.py"
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
G="$T/guven"; mkdir -p "$G/onayli-depo" "$G/onaysiz-depo" "$G/ust/alt" "$T/baska"
git -C "$G/onayli-depo" init -q; git -C "$G/onaysiz-depo" init -q
"$PY" - "$G" "$G/onayli-depo" > "$T/claude.json" <<'JS'
import json,os,sys
print(json.dumps({"projects":{os.path.realpath(a).replace(os.sep,"/"):{"hasTrustDialogAccepted":True} for a in sys.argv[1:]}}))
JS
export SHEEPDOG_CLAUDE_JSON="$T/claude.json"
kod 0 "onaylı git deposu" "$PY" guven.py "$G/onayli-depo"
kod 1 "üstü onaylı ama kendisi onaysız git deposu" "$PY" guven.py "$G/onaysiz-depo"
kod 0 "git dışı klasör üstten onay alır" "$PY" guven.py "$G/ust/alt"
kod 1 "hiçbir üstü onaylı olmayan klasör" "$PY" guven.py "$T/baska"
unset SHEEPDOG_CLAUDE_JSON

echo "deneme/kur.sh"
kod 0 "deneme kurucusu bash sözdizimi" bash -n deneme/kur.sh
# Önce dolu hedef: henüz kartlar yok, red nedeni kart çakışması olamaz.
DOLU="$T/dolu hedef"; mkdir "$DOLU"
printf 'korunacak\n' > "$DOLU/.gizli"
kod 1 "dolu hedef reddedilir" bash deneme/kur.sh "$DOLU"
icerir "dolu hedef açıklaması" "Hedef boş bir klasör olmalı"
if [ "$(cat "$DOLU/.gizli")" = korunacak ] && [ "$(ls -A "$DOLU" | wc -l | tr -d ' ')" = 1 ] \
  && [ ! -e isler/901-iade-hatasi ] && [ ! -e isler/902-gecikme-listesi ] && [ ! -e isler/903-kullanim-notu ]; then
  gecti "dolu hedef ve kartlar değişmedi"
else kaldi "dolu hedef reddinde dosyalar değişti"; fi

# Ayrı global config, kullanıcının ayarını okumadan/yazmadan kimlik yedeğini sınar.
DENEME_GIT_CONFIG="$T/deneme-global-config"
printf '[init]\n\tdefaultBranch = baska\n' > "$DENEME_GIT_CONFIG"
cp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
D="$T/kitaplık denemesi"
kod 0 "geçici hedefe kurulum" env GIT_CONFIG_GLOBAL="$DENEME_GIT_CONFIG" GIT_CONFIG_NOSYSTEM=1 bash deneme/kur.sh "$D"
icerir "kurulum sonraki adımları gösterir" "claude --agent sheepdog --name sheepdog --permission-mode auto"
icerir "güven onayı adımı" "güven onayını"
icerir "başlatma isteği" "hazır kartları başlat"
icerir "canlı pano komutu" "./pano.sh --izle"
kod 0 "hedefte git deposu" git -C "$D" rev-parse --is-inside-work-tree
icerir "git deposu doğrulaması" "true"
kod 0 "hedefte ilk commit" git -C "$D" rev-parse --verify HEAD
DENEME_ILK="$SON"
kod 0 "hedef main dalında" git -C "$D" branch --show-current
icerir "ana dal adı" "main"
kod 0 "yalnız yerel kimlik adı" git -C "$D" config --local --get user.name
icerir "yedek ad" "deneme"
kod 0 "yalnız yerel kimlik e-postası" git -C "$D" config --local --get user.email
icerir "yedek e-posta" "deneme@example.invalid"
kod 0 "global ayar aynı kaldı" cmp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
kod 0 "projenin başlangıç testleri" bash -c 'cd "$1" && PYTHONUTF8=1 "$2" -m unittest' _ "$D" "$PY"
icerir "başlangıçta 8 test" "Ran 8 tests"
icerir "başlangıç test sonucu" "OK"
kod 0 "erken iade hatasını yeniden üret" bash -c 'cd "$1" && PYTHONUTF8=1 "$2" -m kitaplik gecikme --son-tarih 2026-01-15 --iade-tarihi 2026-01-01' _ "$D" "$PY"
icerir "bilerek bırakılan negatif gecikme" "Gecikme: -14 gün"
DENEME_MUTLAK="$(PYTHONUTF8=1 "$PY" -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_posix())' "$D")"
for ad in 901-iade-hatasi 902-gecikme-listesi 903-kullanim-notu; do
  if [ -f "isler/$ad/kart.md" ] && grep -qx 'Durum: hazir' "isler/$ad/kart.md" \
    && grep -qxF "Proje: $DENEME_MUTLAK" "isler/$ad/kart.md"; then
    gecti "hazır kart ve mutlak proje yolu: $ad"
  else kaldi "kart veya proje yolu yanlış: $ad" "beklenen: Proje: $DENEME_MUTLAK | kartta: $(grep -m1 '^Proje:' "isler/$ad/kart.md" 2>/dev/null) | $(grep -m1 '^Durum:' "isler/$ad/kart.md" 2>/dev/null)"; fi
done
if grep -F '{{PROJE}}' isler/90*/kart.md; then kaldi "kartlarda yer tutucu kaldı"; else gecti "kartlarda yer tutucu yok"; fi
kod 0 "deneme kartları başlatılabilirlik" ./pano.sh --baslayabilir
icerir "901 başlayabilir" "901-iade-hatasi"
icerir "902 başlayabilir" "902-gecikme-listesi"
icermez "903 bağımlı, başlayamaz" "903-kullanim-notu"
cp isler/901-iade-hatasi/kart.md "$T/deneme-kart-once"
kod 1 "aynı hedefe ikinci kurulum reddedilir" bash deneme/kur.sh "$D"
kod 1 "aynı adlı kart yeni hedefi engeller" bash deneme/kur.sh "$T/kurulmamali"
icerir "kart çakışması açıklaması" "Kart zaten var"
if [ ! -e "$T/kurulmamali" ]; then gecti "kart çakışmasında hedef oluşturulmadı"; else kaldi "çakışmada hedefe yazıldı"; fi
kod 0 "mevcut kartın üzerine yazılmadı" cmp isler/901-iade-hatasi/kart.md "$T/deneme-kart-once"
if [ "$(git -C "$D" rev-parse HEAD)" = "$DENEME_ILK" ] && [ -z "$(git -C "$D" status --porcelain)" ]; then
  gecti "tekrar kurulum projeyi değiştirmedi"
else kaldi "tekrar kurulum projeyi değiştirdi"; fi

# Boş ama önceden var olan hedef ve mevcut global kimlik de desteklenir.
E="$T/ikinci-merkez"; mkdir "$E" "$T/bos-hedef"
cp -R deneme "$E/deneme"
git config --file "$DENEME_GIT_CONFIG" user.name "Ornek Kullanici"
git config --file "$DENEME_GIT_CONFIG" user.email "ornek@example.invalid"
cp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
kod 0 "mevcut boş hedefe kurulum" env GIT_CONFIG_GLOBAL="$DENEME_GIT_CONFIG" GIT_CONFIG_NOSYSTEM=1 bash "$E/deneme/kur.sh" "$T/bos-hedef"
kod 1 "global kimlik varsa yerel ad yazılmaz" git -C "$T/bos-hedef" config --local --get user.name
kod 1 "global kimlik varsa yerel e-posta yazılmaz" git -C "$T/bos-hedef" config --local --get user.email
kod 0 "mevcut global kimlik değişmedi" cmp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"

echo "ana-dal.sh, tur.sh, çoklu bağımlılık, master"
M="$T/master-proje"; mkdir -p "$M"; g2(){ git -C "$M" -c user.name=t -c user.email=t@x "$@"; }
g2 init -q -b master && echo a > "$M/a" && g2 add . && g2 commit -qm ilk && g2 checkout -q -b dal && echo b > "$M/b" && g2 add . && g2 commit -qm dal && g2 checkout -q master
kod 0 "ana-dal.sh master bulur" ./ana-dal.sh "$M"
icerir "ana dal adı master" "master"
kod 0 "hazırlık hedefi otomatik (master)" ./birlestirme-hazirla.sh "$M" dal
icerir "TEMIZ" "TEMIZ"
kod 1 "ana-dal.sh git olmayan klasörde hata" ./ana-dal.sh "$T/yok-klasor"
printf '1 007-g calisiyor\n2 007-g inceleme\n3 007-g calisiyor\n' > .gecmis
kod 0 "tur.sh" ./tur.sh isler/007-g
icerir "iki tur" "2"
kart 010-x hazir "001-a,004-d"; kart 011-y hazir "001-a,001-a"
kod 0 "çoklu bağımlılık" ./pano.sh --baslayabilir
icermez "bitmeyen bağımlılık başlamaz" "010-x"
icerir "tüm bağımlılıklar bitmiş başlar" "011-y"
kart 012-z hazir "~/yok"; sed -i 's#^Proje: .*#Proje: ~/olmayan-klasor-xyz#' isler/012-z/kart.md
kod 1 "tilde yolu açılır, klasör yoksa hata" ./baslat.sh isler/012-z isci
icerir "açılmış yol" "$HOME/olmayan-klasor-xyz"

echo "sheepdog (front door)"
mkdir -p isler-yedek; rm -rf isler-yedek
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
icerir "yeni kart yolu" "demo-is/kart.md"
KN="$(ls -d isler/[0-9][0-9][0-9]-demo-is)"; grep -q '^Tür: icerik' "$KN/kart.md" && grep -q '^Bekliyor: 001-a' "$KN/kart.md" && grep -q '^Durum: taslak' "$KN/kart.md" && gecti "yeni kart alanları" || kaldi "yeni kart alanları"
kod 2 "new geçersiz slug" ./sheepdog new "Bad Slug" --project "$T"
kod 2 "new proje zorunlu" ./sheepdog new x-y
kod 0 "rounds" ./sheepdog rounds 007-g
kod 0 "timeline" ./sheepdog timeline
icerir "timeline kart" "007-g"
kod 0 "ready" ./sheepdog ready
kod 0 "board" ./sheepdog board

echo
echo "sonuç: $OK geçti, $HATA hata"
[ "$HATA" = 0 ]
