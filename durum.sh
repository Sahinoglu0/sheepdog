#!/bin/bash
# Kart durumunu değiştiren tek yer. kullanım: ./durum.sh isler/001-is <durum>
cd "$(dirname "$0")"; K="${1%/}"; Y="$2"
case "$Y" in taslak|hazir|calisiyor|inceleme|dogrulama|birlesme-bekliyor|birlesiyor|bitti|tikandi) ;; *) echo "Geçersiz durum: $Y"; exit 1;; esac
[ -f "$K/kart.md" ] || { echo "Kart yok: $K"; exit 1; }
T="$K/.kart.$$"; sed "s/^Durum: .*/Durum: $Y/" "$K/kart.md" > "$T" && mv "$T" "$K/kart.md"
printf '%s %s %s\n' "$(date +%s)" "$(basename "$K")" "$Y" >> .gecmis
echo "$(basename "$K"): $Y"
