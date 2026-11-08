#!/bin/bash
# Kart durum tablosu, model harcamaz.
# kullanım: ./pano.sh | ./pano.sh --baslayabilir (başlatılabilir kartlar) | ./pano.sh --izle [saniye] (canlı tablo)
cd "$(dirname "$0")"
alan(){ sed -n "s/^$1: //p" "$2" | head -1; }
if [ "$1" = "--izle" ]; then
  while :; do clear 2>/dev/null || printf '\033[2J\033[H'; date '+%H:%M:%S'; "./$(basename "$0")"; sleep "${2:-10}"; done
fi
if [ "$1" = "--baslayabilir" ]; then
  for k in isler/*/kart.md; do [ -f "$k" ] || continue
    [ "$(alan Durum "$k")" = hazir ] || continue
    b="$(alan Bekliyor "$k")"; [ -z "$b" ] && b=yok
    ok=1; if [ "$b" != yok ]; then for x in $(echo "$b" | tr ',' ' '); do [ "$(alan Durum "isler/$x/kart.md" 2>/dev/null)" = bitti ] || ok=0; done; fi
    [ "$ok" = 1 ] && basename "$(dirname "$k")"
  done; exit 0
fi
printf '%-26s %-19s %-8s %-24s %s\n' KART DURUM TUR BEKLIYOR PROJE
for k in isler/*/kart.md; do [ -f "$k" ] || continue
  printf '%-26s %-19s %-8s %-24s %s\n' "$(basename "$(dirname "$k")")" "$(alan Durum "$k")" "$(alan Tür "$k")" "$(alan Bekliyor "$k")" "$(alan Proje "$k" | sed "s#$HOME#~#")"
done
OZET="$(for k in isler/*/kart.md; do [ -f "$k" ] && alan Durum "$k"; done | sort | uniq -c | awk '{printf "%s%s %s", (NR>1?", ":""), $1, $2}')"
[ -n "$OZET" ] && echo && echo "özet: $OZET"
for k in isler/*/kart.md; do [ -f "$k" ] || continue
  [ "$(alan Durum "$k")" = tikandi ] && echo "dikkat: $(basename "$(dirname "$k")") tıkandı, süper ajana sorun"
done
exit 0
