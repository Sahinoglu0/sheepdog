#!/bin/bash
# kullanım: ./kontrol.sh [proje-klasörü ...]
# Makineyi yoklar, hiçbir şeyi değiştirmez. Zorunlu kontrollerden biri kalırsa çıkış kodu 1.
MIN="2.1.293"
KOK="$(cd "$(dirname "$0")" && pwd)"
HATA=0
tamam() { echo "tamam: $1"; }
eksik() { echo "EKSİK: $1"; HATA=1; }
uyari() { echo "uyarı: $1"; }

# a.b.c sürümü en az MIN mi (sort -V her sistemde yok)
surum_yeter() { local IFS=.; set -- $1 $2; local i
  for i in 1 2 3; do eval "x=\${$i:-0}; y=\${$((i+3)):-0}"; [ "$x" -gt "$y" ] && return 0; [ "$x" -lt "$y" ] && return 1; done; return 0; }

for k in git bash; do
  if command -v "$k" >/dev/null 2>&1; then tamam "$k var"; else eksik "$k bulunamadı, kurun ve PATH'e ekleyin"; fi
done
PY=""
for k in python3 python; do if command -v "$k" >/dev/null 2>&1 && "$k" -c "import sys; sys.exit(sys.version_info < (3, 8))" 2>/dev/null; then PY="$k"; break; fi; done
if [ -n "$PY" ]; then tamam "python var ($PY)"; else eksik "python 3.8 veya sonrası bulunamadı (python3 ya da python), kurun ve PATH'e ekleyin"; fi
if command -v git >/dev/null 2>&1; then
  GS="$(git --version | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)"
  if surum_yeter "$GS" "2.38.0"; then tamam "git sürümü $GS (en az 2.38)"; else eksik "git sürümü $GS, birleştirme provası için en az 2.38 gerekli"; fi
fi

if ! command -v claude >/dev/null 2>&1; then
  eksik "claude komutu bulunamadı, Claude Code'u kurun ve PATH'e ekleyin"
else
  tamam "claude var"
  SURUM="$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ -z "$SURUM" ]; then
    eksik "claude sürümü okunamadı, 'claude --version' çalışmıyor"
  elif ! surum_yeter "$SURUM" "$MIN"; then
    eksik "claude sürümü $SURUM, en az $MIN gerekli, claude'u güncelleyin"
  else
    tamam "claude sürümü $SURUM (en az $MIN)"
  fi

  YARDIM="$(claude --help 2>&1)"
  if printf '%s\n' "$YARDIM" | grep -qE -- '--bg\b'; then tamam "claude --bg destekleniyor"
  else eksik "claude --bg desteklenmiyor, claude'u güncelleyin"; fi

  if claude agents --help 2>&1 | grep -q 'claude agents'; then tamam "claude agents destekleniyor"
  else eksik "claude agents desteklenmiyor, claude'u güncelleyin"; fi

  if printf '%s\n' "$YARDIM" | grep -A3 -- '--permission-mode' | grep -q '"auto"'; then
    tamam "otomatik izin modu (auto) yardım çıktısında görünüyor"
  else
    uyari "otomatik izin modu (auto) yardım çıktısında görünmüyor, baslat.sh --permission-mode auto kullanır"
  fi
fi

if [ "$#" -gt 0 ]; then
  if [ -z "$PY" ] || ! command -v git >/dev/null 2>&1; then
    uyari "güven onayı kontrol edilemedi: python ve git gerekli"
  else
    for P in "$@"; do
      if [ ! -d "$P" ]; then uyari "proje klasörü yok: $P"; continue; fi
      # baslat.sh ile aynı mantık: git deposunda klasörün kendisi veya git kökü onaylı olmalı.
      if "$PY" "$KOK/guven.py" "$P"
      then tamam "güven onayı var: $P"
      else uyari "güven onayı yok: $P içinde bir kez claude açıp onay verin"; fi
    done
  fi
fi

if [ "$HATA" -eq 0 ]; then echo "sonuç: zorunlu kontroller geçti"; else echo "sonuç: zorunlu kontrollerde eksik var"; fi
exit "$HATA"
