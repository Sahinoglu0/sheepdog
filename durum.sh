#!/bin/bash
# The only place that changes a card's state. / Kart durumunu değiştiren tek yer.
# usage / kullanım: ./durum.sh isler/001-is <state|durum>   (Turkish or English state names)
cd "$(dirname "$0")"; . ./dil.sh; K="${1%/}"; Y="$(ndurum "$2")"
case "$Y" in taslak|hazir|calisiyor|inceleme|dogrulama|birlesme-bekliyor|birlesiyor|bitti|tikandi) ;; *) echo "$(T "Geçersiz durum" "Invalid state"): $2"; exit 1;; esac
[ -f "$K/kart.md" ] || { echo "$(T "Kart yok" "No such card"): $K"; exit 1; }
# keep the card's own language: "Status:" cards get English values, "Durum:" cards Turkish ones
if grep -q '^Status: ' "$K/kart.md"; then ANAHTAR=Status; DEGER="$(edurum "$Y")"; else ANAHTAR=Durum; DEGER="$Y"; fi
T="$K/.kart.$$"; sed -E "s/^(Durum|Status): .*/$ANAHTAR: $DEGER/" "$K/kart.md" > "$T" && mv "$T" "$K/kart.md"
printf '%s %s %s\n' "$(date +%s)" "$(basename "$K")" "$Y" >> .gecmis
echo "$(basename "$K"): $(gdurum "$Y")"
