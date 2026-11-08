#!/bin/bash
# usage: ./launch.sh jobs/001-task [worker|reviewer|verifier|merger]   (Turkish aliases isci, dogrulayici, birlestirici also work)
set -e
HUB="$(cd "$(dirname "$0")" && pwd)"; . "$HUB/lang.sh"; K="${1%/}"; ROL="$(nrole "${2:-worker}")"
CARD="$HUB/$K/card.md"; AD="$(basename "$K")"
[ -f "$CARD" ] || { echo "$(T "Kart yok" "No such card"): $CARD"; exit 1; }
ROLEFILE="$HUB/roles/$SHEEPDOG_LANG/$ROL.md"
[ -f "$ROLEFILE" ] || { echo "$(T "Rol yok" "No such role"): $ROL"; exit 1; }
PROJECT="$(field Proje "$CARD")"
case "$PROJECT" in "~"|"~/"*) PROJECT="$HOME${PROJECT#\~}";; esac
[ -d "$PROJECT" ] || { echo "$(T "Proje klasörü yok" "Project folder not found"): $PROJECT"; exit 1; }
[ "$ROL" != worker ] || [ "$(nstate "$(field Durum "$CARD")")" != done ] || { echo "$(T "Kart zaten bitti; işçi yeniden başlatılmaz" "Card is already done; not relaunching a worker"): $CARD" >&2; exit 1; }
[ "$ROL" != merger ] || [ "$(policy_of)" != ask ] || approved "$(basename "$K")" || { echo "$(T "ONAY GEREKLİ" "APPROVAL NEEDED"): $(basename "$K") $(T "için birleştirici başlatılamaz: politika ask. Kullanıcıya sorun; evet derse: ./sheepdog approve" "cannot launch the merger: the policy is ask. Ask the user; if they say yes run: ./sheepdog approve") $(basename "$K")" >&2; exit 1; }
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
"$PY" "$HUB/trust.py" "$PROJECT" || { echo "$(T "Güven onayı yok: $PROJECT içinde bir kez claude açıp onay verin" "No trust approval: open claude once inside $PROJECT and accept the trust prompt")"; exit 2; }
MODEL_WORKER=sonnet; EFFORT_WORKER=medium
MODEL_REVIEWER=sonnet; EFFORT_REVIEWER=medium
MODEL_VERIFIER=haiku; EFFORT_VERIFIER=medium
MODEL_MERGER=sonnet; EFFORT_MERGER=medium
if [ -f "$HUB/settings.sh" ]; then source "$HUB/settings.sh"; fi
case "$ROL" in
  worker)
    AD2="$AD"; MODEL="$MODEL_WORKER"; EF="$EFFORT_WORKER"
    if grep -qE '^Model: ' "$CARD" || grep -qE '^Model:$' "$CARD"; then MODEL="$(field Model "$CARD")"; fi
    if grep -qE '^(Efor|Effort):' "$CARD"; then EF="$(field Effort "$CARD")"; fi
    ;;
  reviewer) AD2="$AD-reviewer"; MODEL="$MODEL_REVIEWER"; EF="$EFFORT_REVIEWER";;
  verifier) AD2="$AD-verifier"; MODEL="$MODEL_VERIFIER"; EF="$EFFORT_VERIFIER";;
  merger) AD2="$AD-merger"; MODEL="$MODEL_MERGER"; EF="$EFFORT_MERGER";;
esac
for m in "$MODEL" "$EF"; do case "$m" in -*|*[!A-Za-z0-9._-]*|"") echo "$(T "Geçersiz model/efor" "Invalid model/effort"): '$m' (settings.sh / card)" >&2; exit 1;; esac; done
case "$EF" in low|medium|high) ;; *) echo "$(T "Geçersiz efor" "Invalid effort"): '$EF' ($(T rol role): $ROL; $(T beklenen expected): low, medium, high)" >&2; exit 1;; esac
cd "$PROJECT"
if [ "${SHEEPDOG_DRY:-}" = 1 ]; then
  printf '%q ' "${SHEEPDOG_CLAUDE:-claude}" --bg ${SHEEPDOG_FLAGS:-} --permission-mode auto --model "$MODEL" --effort "$EF" --append-system-prompt-file "$ROLEFILE" --add-dir "$HUB/$K" --name "$AD2" -- "$(T "Kartın: $CARD. Rolüne göre işini yap ve kartın klasörüne yaz." "Your card: $CARD. Do your role's job and write your output into the card's folder.")"
  printf '\n'
  exit 0
fi
"${SHEEPDOG_CLAUDE:-claude}" --bg ${SHEEPDOG_FLAGS:-} --permission-mode auto --model "$MODEL" --effort "$EF" --append-system-prompt-file "$ROLEFILE" --add-dir "$HUB/$K" --name "$AD2" -- "$(T "Kartın: $CARD. Rolüne göre işini yap ve kartın klasörüne yaz." "Your card: $CARD. Do your role's job and write your output into the card's folder.")"
[ "$ROL" = worker ] && "$HUB/state.sh" "$K" working >/dev/null
echo "$(T başladı started): $AD2 ($PROJECT)"
