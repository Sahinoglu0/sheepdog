#!/bin/bash
# Card board, no model cost.
# usage: ./board.sh | ./board.sh --startable (cards that can start now) | ./board.sh --watch [secs] (live)
cd "$(dirname "$0")"; . ./lang.sh
if [ "$1" = "--watch" ]; then
  while :; do clear 2>/dev/null || printf '\033[2J\033[H'; date '+%H:%M:%S'; "./$(basename "$0")"; sleep "${2:-10}"; done
fi
state_of(){ nstate "$(field Durum "$1")"; }
if [ "$1" = "--startable" ]; then
  for k in jobs/*/card.md; do [ -f "$k" ] || continue
    [ "$(state_of "$k")" = ready ] || continue
    b="$(field Bekliyor "$k")"; case "$b" in ""|none|None|-|yok) b=none;; esac
    ok=1; if [ "$b" != none ]; then for x in $(echo "$b" | tr ',' ' '); do [ "$(state_of "jobs/$x/card.md" 2>/dev/null)" = done ] || ok=0; done; fi
    [ "$ok" = 1 ] && basename "$(dirname "$k")"
  done; exit 0
fi
printf '%-26s %-19s %-8s %-24s %s\n' "$(T KART CARD)" "$(T DURUM STATE)" "$(T TUR TYPE)" "$(T BEKLIYOR WAITS-FOR)" "$(T PROJE PROJECT)"
for k in jobs/*/card.md; do [ -f "$k" ] || continue
  tur="$(ntype "$(field Tür "$k")")"; [ "$SHEEPDOG_LANG" != tr ] || case "$tur" in code) tur=kod;; content) tur=icerik;; esac
  printf '%-26s %-19s %-8s %-24s %s\n' "$(basename "$(dirname "$k")")" "$(dstate "$(state_of "$k")")" "$tur" "$(field Bekliyor "$k")" "$(field Proje "$k" | sed "s#$HOME#~#")"
done
SUMMARY="$(for k in jobs/*/card.md; do [ -f "$k" ] && dstate "$(state_of "$k")"; done | sort | uniq -c | awk '{printf "%s%s %s", (NR>1?", ":""), $1, $2}')"
[ -n "$SUMMARY" ] && echo && echo "$(T özet summary): $SUMMARY"
for k in jobs/*/card.md; do [ -f "$k" ] || continue
  [ "$(state_of "$k")" = stuck ] && echo "$(T dikkat attention): $(basename "$(dirname "$k")") $(T "tıkandı, Sheepdog'a sorun" "is stuck, ask Sheepdog")"
done
exit 0
