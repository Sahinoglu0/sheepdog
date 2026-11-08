#!/bin/bash
# Card board, no model cost. / Kart durum tablosu, model harcamaz.
# usage: ./pano.sh | ./pano.sh --baslayabilir (startable cards) | ./pano.sh --izle [secs] (live)
cd "$(dirname "$0")"; . ./dil.sh
if [ "$1" = "--izle" ]; then
  while :; do clear 2>/dev/null || printf '\033[2J\033[H'; date '+%H:%M:%S'; "./$(basename "$0")"; sleep "${2:-10}"; done
fi
durum_of(){ ndurum "$(alan Durum "$1")"; }
if [ "$1" = "--baslayabilir" ]; then
  for k in isler/*/kart.md; do [ -f "$k" ] || continue
    [ "$(durum_of "$k")" = hazir ] || continue
    b="$(alan Bekliyor "$k")"; [ -z "$b" ] && b=yok; case "$b" in none|None|-) b=yok;; esac
    ok=1; if [ "$b" != yok ]; then for x in $(echo "$b" | tr ',' ' '); do [ "$(durum_of "isler/$x/kart.md" 2>/dev/null)" = bitti ] || ok=0; done; fi
    [ "$ok" = 1 ] && basename "$(dirname "$k")"
  done; exit 0
fi
printf '%-26s %-19s %-8s %-24s %s\n' "$(T KART CARD)" "$(T DURUM STATE)" "$(T TUR TYPE)" "$(T BEKLIYOR WAITS-FOR)" "$(T PROJE PROJECT)"
for k in isler/*/kart.md; do [ -f "$k" ] || continue
  tur="$(alan Tür "$k")"; [ "$SHEEPDOG_LANG" = tr ] || case "$tur" in kod) tur=code;; icerik) tur=content;; esac
  printf '%-26s %-19s %-8s %-24s %s\n' "$(basename "$(dirname "$k")")" "$(gdurum "$(durum_of "$k")")" "$tur" "$(alan Bekliyor "$k")" "$(alan Proje "$k" | sed "s#$HOME#~#")"
done
OZET="$(for k in isler/*/kart.md; do [ -f "$k" ] && gdurum "$(durum_of "$k")"; done | sort | uniq -c | awk '{printf "%s%s %s", (NR>1?", ":""), $1, $2}')"
[ -n "$OZET" ] && echo && echo "$(T özet summary): $OZET"
for k in isler/*/kart.md; do [ -f "$k" ] || continue
  [ "$(durum_of "$k")" = tikandi ] && echo "$(T dikkat attention): $(basename "$(dirname "$k")") $(T "tıkandı, Sheepdog'a sorun" "is stuck, ask Sheepdog")"
done
exit 0
