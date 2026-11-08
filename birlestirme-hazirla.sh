#!/bin/bash
# Birleştirme provası: ana dala dokunmaz. kullanım: ./birlestirme-hazirla.sh <proje> <dal> [hedef-dal]
P="$1"; D="$2"; H="${3:-$("$(dirname "$0")/ana-dal.sh" "$P" 2>/dev/null)}"; H="${H:-main}"
git -C "$P" rev-parse --verify -q "$D" >/dev/null || { echo "Dal yok: $D"; exit 2; }
git -C "$P" rev-parse --verify -q "$H" >/dev/null || { echo "Hedef dal yok: $H"; exit 2; }
a="$(git -C "$P" rev-list --count "$D..$H")"; c="$(git -C "$P" rev-list --count "$H..$D")"
if o="$(git -C "$P" merge-tree --write-tree --name-only "$H" "$D" 2>&1)"; then
  echo "TEMIZ: $D -> $H birleşebilir. $c yeni commit, hedef $a commit önde. Ana dal değişmedi."; git -C "$P" diff --stat "$H...$D" | tail -1
else
  echo "CAKISMA: $D -> $H. Ana dal değişmedi. Dosyalar:"; printf '%s\n' "$o" | sed -n '2,/^$/p'; exit 1
fi
