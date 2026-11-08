#!/bin/bash
# kullanım: ./baslat.sh isler/001-is [isci|reviewer|dogrulayici|birlestirici]
set -e
MERKEZ="$(cd "$(dirname "$0")" && pwd)"; K="${1%/}"; ROL="${2:-isci}"
KART="$MERKEZ/$K/kart.md"; AD="$(basename "$K")"
[ -f "$KART" ] || { echo "Kart yok: $KART"; exit 1; }
[ -f "$MERKEZ/roller/$ROL.md" ] || { echo "Rol yok: $ROL"; exit 1; }
PROJE="$(sed -n 's/^Proje: //p' "$KART" | head -1)"
case "$PROJE" in "~"|"~/"*) PROJE="$HOME${PROJE#\~}";; esac
[ -d "$PROJE" ] || { echo "Proje klasörü yok: $PROJE"; exit 1; }
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
"$PY" "$MERKEZ/guven.py" "$PROJE" || { echo "Güven onayı yok: $PROJE içinde bir kez claude açıp onay verin"; exit 2; }
MODEL_ISCI=sonnet; EFOR_ISCI=high
MODEL_INCELEMECI=sonnet; EFOR_INCELEMECI=high
MODEL_DOGRULAYICI=sonnet; EFOR_DOGRULAYICI=medium
MODEL_BIRLESTIRICI=sonnet; EFOR_BIRLESTIRICI=high
if [ -f "$MERKEZ/ayarlar.sh" ]; then source "$MERKEZ/ayarlar.sh"; fi
case "$ROL" in
  isci)
    AD2="$AD"; MODEL="$MODEL_ISCI"; EF="$EFOR_ISCI"
    if grep -q '^Model: ' "$KART"; then MODEL="$(sed -n 's/^Model: //p' "$KART" | head -1)"; fi
    if grep -q '^Efor: ' "$KART"; then EF="$(sed -n 's/^Efor: //p' "$KART" | head -1)"; fi
    ;;
  reviewer) AD2="$AD-reviewer"; MODEL="$MODEL_INCELEMECI"; EF="$EFOR_INCELEMECI";;
  dogrulayici) AD2="$AD-dogrulayici"; MODEL="$MODEL_DOGRULAYICI"; EF="$EFOR_DOGRULAYICI";;
  birlestirici) AD2="$AD-birlestirici"; MODEL="$MODEL_BIRLESTIRICI"; EF="$EFOR_BIRLESTIRICI";;
esac
for m in "$MODEL" "$EF"; do case "$m" in *[!A-Za-z0-9._-]*|"") echo "Geçersiz model/efor: '$m' (ayarlar.sh ya da kart)" >&2; exit 1;; esac; done
case "$EF" in low|medium|high) ;; *) echo "Geçersiz efor: '$EF' (rol: $ROL; beklenen: low, medium, high)" >&2; exit 1;; esac
cd "$PROJE"
if [ "${SHEEPDOG_KURU:-}" = 1 ]; then
  printf '%q ' claude --bg ${SHEEPDOG_BAYRAK:-} --permission-mode auto --model "$MODEL" --effort "$EF" --append-system-prompt-file "$MERKEZ/roller/$ROL.md" --add-dir "$MERKEZ/$K" --name "$AD2" -- "Kartın: $KART. Rolüne göre işini yap ve kartın klasörüne yaz."
  printf '\n'
  exit 0
fi
claude --bg ${SHEEPDOG_BAYRAK:-} --permission-mode auto --model "$MODEL" --effort "$EF" --append-system-prompt-file "$MERKEZ/roller/$ROL.md" --add-dir "$MERKEZ/$K" --name "$AD2" -- "Kartın: $KART. Rolüne göre işini yap ve kartın klasörüne yaz."
[ "$ROL" = isci ] && "$MERKEZ/durum.sh" "$K" calisiyor >/dev/null
echo "başladı: $AD2 ($PROJE)"
