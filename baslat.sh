#!/bin/bash
# usage / kullanım: ./baslat.sh isler/001-is [isci|reviewer|dogrulayici|birlestirici]  (aliases: worker, verifier, merger)
set -e
MERKEZ="$(cd "$(dirname "$0")" && pwd)"; . "$MERKEZ/dil.sh"; K="${1%/}"; ROL="$(nrol "${2:-isci}")"
KART="$MERKEZ/$K/kart.md"; AD="$(basename "$K")"
[ -f "$KART" ] || { echo "$(T "Kart yok" "No such card"): $KART"; exit 1; }
ROLDOSYA="$MERKEZ/roller/$SHEEPDOG_LANG/$ROL.md"
[ -f "$ROLDOSYA" ] || { echo "$(T "Rol yok" "No such role"): $ROL"; exit 1; }
PROJE="$(alan Proje "$KART")"
case "$PROJE" in "~"|"~/"*) PROJE="$HOME${PROJE#\~}";; esac
[ -d "$PROJE" ] || { echo "$(T "Proje klasörü yok" "Project folder not found"): $PROJE"; exit 1; }
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
"$PY" "$MERKEZ/guven.py" "$PROJE" || { echo "$(T "Güven onayı yok: $PROJE içinde bir kez claude açıp onay verin" "No trust approval: open claude once inside $PROJE and accept the trust prompt")"; exit 2; }
MODEL_ISCI=sonnet; EFOR_ISCI=high
MODEL_INCELEMECI=sonnet; EFOR_INCELEMECI=high
MODEL_DOGRULAYICI=sonnet; EFOR_DOGRULAYICI=medium
MODEL_BIRLESTIRICI=sonnet; EFOR_BIRLESTIRICI=high
if [ -f "$MERKEZ/ayarlar.sh" ]; then source "$MERKEZ/ayarlar.sh"; fi
case "$ROL" in
  isci)
    AD2="$AD"; MODEL="$MODEL_ISCI"; EF="$EFOR_ISCI"
    if grep -qE '^Model: ' "$KART" || grep -qE '^Model:$' "$KART"; then MODEL="$(alan Model "$KART")"; fi
    if grep -qE '^(Efor|Effort):' "$KART"; then EF="$(alan Efor "$KART")"; fi
    ;;
  reviewer) AD2="$AD-reviewer"; MODEL="$MODEL_INCELEMECI"; EF="$EFOR_INCELEMECI";;
  dogrulayici) AD2="$AD-dogrulayici"; MODEL="$MODEL_DOGRULAYICI"; EF="$EFOR_DOGRULAYICI";;
  birlestirici) AD2="$AD-birlestirici"; MODEL="$MODEL_BIRLESTIRICI"; EF="$EFOR_BIRLESTIRICI";;
esac
for m in "$MODEL" "$EF"; do case "$m" in *[!A-Za-z0-9._-]*|"") echo "$(T "Geçersiz model/efor" "Invalid model/effort"): '$m' (ayarlar.sh / card)" >&2; exit 1;; esac; done
case "$EF" in low|medium|high) ;; *) echo "$(T "Geçersiz efor" "Invalid effort"): '$EF' ($(T rol role): $ROL; $(T beklenen expected): low, medium, high)" >&2; exit 1;; esac
cd "$PROJE"
if [ "${SHEEPDOG_KURU:-}" = 1 ]; then
  printf '%q ' claude --bg ${SHEEPDOG_BAYRAK:-} --permission-mode auto --model "$MODEL" --effort "$EF" --append-system-prompt-file "$ROLDOSYA" --add-dir "$MERKEZ/$K" --name "$AD2" -- "$(T "Kartın: $KART. Rolüne göre işini yap ve kartın klasörüne yaz." "Your card: $KART. Do your role's job and write your output into the card's folder.")"
  printf '\n'
  exit 0
fi
claude --bg ${SHEEPDOG_BAYRAK:-} --permission-mode auto --model "$MODEL" --effort "$EF" --append-system-prompt-file "$ROLDOSYA" --add-dir "$MERKEZ/$K" --name "$AD2" -- "$(T "Kartın: $KART. Rolüne göre işini yap ve kartın klasörüne yaz." "Your card: $KART. Do your role's job and write your output into the card's folder.")"
[ "$ROL" = isci ] && "$MERKEZ/durum.sh" "$K" calisiyor >/dev/null
echo "$(T başladı started): $AD2 ($PROJE)"
