#!/bin/bash
# The only place that changes a card's state. Accepts English or Turkish state names.
# usage: ./state.sh jobs/001-task <state>
cd "$(dirname "$0")"; . ./lang.sh; K="${1%/}"; Y="$(nstate "$2")"
case "$Y" in draft|ready|working|review|verify|merge-queue|merging|done|stuck) ;; *) echo "$(T "Geçersiz durum" "Invalid state"): $2"; exit 1;; esac
[ -f "$K/card.md" ] || { echo "$(T "Kart yok" "No such card"): $K"; exit 1; }
# Merge approval: with "./sheepdog policy ask" nothing may start merging before "./sheepdog approve <card>".
if [ "$Y" = merging ] && [ "$(policy_of)" = ask ] && ! approved "$(basename "$K")"; then
  echo "$(T "ONAY GEREKLİ" "APPROVAL NEEDED"): $(basename "$K") $(T "birleştirilemez: politika 'ask'. Kullanıcıya sorun; evet derse ./sheepdog approve $(basename "$K")" "may not be merged: the policy is 'ask'. Ask the user; if they say yes run ./sheepdog approve $(basename "$K")")" >&2
  exit 1
fi
# Stage gates: a card cannot skip review, verification or the merge. SHEEPDOG_GATE=off disables them (humans only).
if [ "${SHEEPDOG_GATE:-on}" != off ]; then
  TYPE="$(ntype "$(field Tür "$K/card.md")")"; need=""
  case "$Y" in
    review) need="worker" ;;
    verify|merge-queue|merging) need="reviewer"; [ "$Y" != verify ] && need="reviewer verifier" ;;
    done) if [ "$TYPE" = content ]; then need="reviewer"; else need="reviewer verifier merger"; fi ;;
  esac
  for r in $need; do
    if ! msg="$(./seal.sh verdict "$K" "$r" 2>&1)"; then
      echo "$(T "ATLANAMAZ" "STAGE SKIPPED"): $(basename "$K") -> $(dstate "$Y") $(T "için" "needs") $r: $msg" >&2
      echo "$(T "Önce ilgili rolü başlatın; yalnızca bir insan SHEEPDOG_GATE=off ile aşabilir." "Run that role first; only a human may bypass with SHEEPDOG_GATE=off.")" >&2
      exit 1
    fi
  done
fi
# the card keeps its own language: "Status:" cards get English values, "Durum:" cards Turkish ones
if grep -q '^Status: ' "$K/card.md"; then KEY=Status; VAL="$Y"; else KEY=Durum; VAL="$(tstate "$Y")"; fi
T="$K/.card.$$"; awk -v key="$KEY" -v val="$VAL" '!d && /^(Durum|Status): /{ cr=($0 ~ /\r$/)?"\r":""; print key ": " val cr; d=1; next } {print}' "$K/card.md" > "$T" && mv "$T" "$K/card.md"
printf '%s %s %s\n' "$(date +%s)" "$(basename "$K")" "$Y" >> .history
echo "$(basename "$K"): $(dstate "$Y")"
