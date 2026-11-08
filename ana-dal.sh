#!/bin/bash
# Projenin ana dalının adını yazar (model harcamaz). kullanım: ./ana-dal.sh <proje>
# Sıra: origin/HEAD, şu an çıkış yapılmış dal, main, master.
P="$1"; [ -n "$P" ] || { echo "kullanım: ana-dal.sh <proje>" >&2; exit 2; }
d="$(git -C "$P" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)"; d="${d#origin/}"
[ -n "$d" ] || d="$(git -C "$P" symbolic-ref -q --short HEAD 2>/dev/null)"
for a in "$d" main master; do
  [ -n "$a" ] && git -C "$P" rev-parse --verify -q "refs/heads/$a" >/dev/null && { echo "$a"; exit 0; }
done
echo "Ana dal bulunamadı: $P" >&2; exit 1
