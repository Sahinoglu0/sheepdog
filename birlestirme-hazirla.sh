#!/bin/bash
# Merge dry run: main is never touched. / Birleştirme provası: ana dala dokunmaz.
# usage: ./birlestirme-hazirla.sh <project> <branch> [target-branch]
HQ="$(cd "$(dirname "$0")" && pwd)"; . "$HQ/dil.sh"
P="$1"; D="$2"; H="${3:-$("$HQ/ana-dal.sh" "$P" 2>/dev/null)}"; H="${H:-main}"
git -C "$P" rev-parse --verify -q "$D" >/dev/null || { echo "$(T "Dal yok" "No such branch"): $D"; exit 2; }
git -C "$P" rev-parse --verify -q "$H" >/dev/null || { echo "$(T "Hedef dal yok" "No such target branch"): $H"; exit 2; }
a="$(git -C "$P" rev-list --count "$D..$H")"; c="$(git -C "$P" rev-list --count "$H..$D")"
if o="$(git -C "$P" merge-tree --write-tree --name-only "$H" "$D" 2>&1)"; then
  echo "TEMIZ: $D -> $H $(T "birleşebilir. $c yeni commit, hedef $a commit önde. Ana dal değişmedi." "can merge. $c new commits, target is $a commits ahead. Main unchanged.")"; git -C "$P" diff --stat "$H...$D" | tail -1
else
  echo "CAKISMA: $D -> $H. $(T "Ana dal değişmedi. Dosyalar:" "Main unchanged. Files:")"; printf '%s\n' "$o" | sed -n '2,/^$/p'; exit 1
fi
