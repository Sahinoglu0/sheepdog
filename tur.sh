#!/bin/bash
# Kartın kaç kez çalışmaya (geri gönderme dahil) alındığını yazar. Sayı .gecmis dosyasından gelir,
# süper ajanın hafızasına bağlı değildir. kullanım: ./tur.sh isler/001-is
cd "$(dirname "$0")"; A="$(basename "${1%/}")"
[ -f .gecmis ] || { echo 0; exit 0; }
awk -v a="$A" '$2==a && $3=="calisiyor"{n++} END{print n+0}' .gecmis
