#!/bin/bash
# usage: ./doctor.sh [project-folder ...]
# Checks the machine, changes nothing. Exit 1 if a required check fails.
MIN="2.1.293"
KOK="$(cd "$(dirname "$0")" && pwd)"; . "$KOK/lang.sh"
HATA=0
tamam() { echo "$(T tamam ok): $1"; }
eksik() { echo "$(T EKSİK MISSING): $1"; HATA=1; }
uyari() { echo "$(T uyarı warning): $1"; }

# a.b.c sürümü en az MIN mi (sort -V her sistemde yok)
surum_yeter() { local IFS=.; set -- $1 $2; local i
  for i in 1 2 3; do eval "x=\${$i:-0}; y=\${$((i+3)):-0}"; [ "$x" -gt "$y" ] && return 0; [ "$x" -lt "$y" ] && return 1; done; return 0; }

for k in git bash; do
  if command -v "$k" >/dev/null 2>&1; then tamam "$k $(T var found)"; else eksik "$k $(T "bulunamadı, kurun ve PATH'e ekleyin" "not found, install it and add it to PATH")"; fi
done
PY=""
for k in python3 python; do if command -v "$k" >/dev/null 2>&1 && "$k" -c "import sys; sys.exit(sys.version_info < (3, 8))" 2>/dev/null; then PY="$k"; break; fi; done
if [ -n "$PY" ]; then tamam "python $(T var found) ($PY)"; else eksik "$(T "python 3.8 veya sonrası bulunamadı (python3 ya da python), kurun ve PATH'e ekleyin" "Python 3.8 or newer not found (python3 or python), install it and add it to PATH")"; fi
if command -v git >/dev/null 2>&1; then
  GS="$(git --version | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)"
  if surum_yeter "$GS" "2.38.0"; then tamam "$(T "git sürümü" "git version") $GS ($(T "en az" "at least") 2.38)"; else eksik "$(T "git sürümü $GS, birleştirme provası için en az 2.38 gerekli" "git version $GS, the merge dry run needs at least 2.38")"; fi
fi

if ! command -v claude >/dev/null 2>&1; then
  eksik "$(T "claude komutu bulunamadı, Claude Code'u kurun ve PATH'e ekleyin" "claude command not found, install Claude Code and add it to PATH")"
else
  tamam "claude $(T var found)"
  SURUM="$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ -z "$SURUM" ]; then
    eksik "$(T "claude sürümü okunamadı, 'claude --version' çalışmıyor" "could not read the claude version, 'claude --version' fails")"
  elif ! surum_yeter "$SURUM" "$MIN"; then
    eksik "$(T "claude sürümü $SURUM, en az $MIN gerekli, claude'u güncelleyin" "claude version $SURUM, at least $MIN is required, update claude")"
  else
    tamam "$(T "claude sürümü" "claude version") $SURUM ($(T "en az" "at least") $MIN)"
  fi

  YARDIM="$(claude --help 2>&1)"
  if printf '%s\n' "$YARDIM" | grep -qE -- '--bg\b'; then tamam "$(T "claude --bg destekleniyor" "claude --bg is supported")"
  else eksik "$(T "claude --bg desteklenmiyor, claude'u güncelleyin" "claude --bg is not supported, update claude")"; fi

  if claude agents --help 2>&1 | grep -q 'claude agents'; then tamam "$(T "claude agents destekleniyor" "claude agents is supported")"
  else eksik "$(T "claude agents desteklenmiyor, claude'u güncelleyin" "claude agents is not supported, update claude")"; fi

  if printf '%s\n' "$YARDIM" | grep -A3 -- '--permission-mode' | grep -q '"auto"'; then
    tamam "$(T "otomatik izin modu (auto) yardım çıktısında görünüyor" "auto permission mode appears in the help output")"
  else
    uyari "$(T "otomatik izin modu (auto) yardım çıktısında görünmüyor, launch.sh --permission-mode auto kullanır" "auto permission mode is not in the help output; launch.sh uses --permission-mode auto anyway")"
  fi
fi

# Windows: Claude Code needs Git Bash for its shell tool. If Git lives in a non-standard place the manager
# session starts WITHOUT a shell and cannot run any script (seen in a real trial run).
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*)
  if [ -n "${CLAUDE_CODE_GIT_BASH_PATH:-}" ]; then tamam "CLAUDE_CODE_GIT_BASH_PATH $(T ayarlı set): $CLAUDE_CODE_GIT_BASH_PATH"
  else uyari "$(T "Windows: CLAUDE_CODE_GIT_BASH_PATH ayarlı değil. Git standart yerde değilse (ör. başka bir programın içinde) Sheepdog oturumu kabuk aracı olmadan açılır. Örnek: export CLAUDE_CODE_GIT_BASH_PATH='C:\\yol\\git\\bin\\bash.exe'" "Windows: CLAUDE_CODE_GIT_BASH_PATH is not set. If Git is not in its standard place (for example bundled inside another program) the Sheepdog session starts without a shell tool. Example: export CLAUDE_CODE_GIT_BASH_PATH='C:\\path\\to\\git\\bin\\bash.exe'")"; fi ;;
esac

if [ "$#" -gt 0 ]; then
  if [ -z "$PY" ] || ! command -v git >/dev/null 2>&1; then
    uyari "$(T "güven onayı kontrol edilemedi: python ve git gerekli" "cannot check trust approval: python and git are required")"
  else
    for P in "$@"; do
      if [ ! -d "$P" ]; then uyari "$(T "proje klasörü yok" "project folder not found"): $P"; continue; fi
      # launch.sh ile aynı mantık: git deposunda klasörün kendisi veya git kökü onaylı olmalı.
      if "$PY" "$KOK/trust.py" "$P"
      then tamam "$(T "güven onayı var" "trust approved"): $P"
      else uyari "$(T "güven onayı yok: $P içinde bir kez claude açıp onay verin" "no trust approval: open claude once inside $P and accept the trust prompt")"; fi
    done
  fi
fi

if [ "$HATA" -eq 0 ]; then echo "$(T sonuç result): $(T "zorunlu kontroller geçti" "required checks passed")"; else echo "$(T sonuç result): $(T "zorunlu kontrollerde eksik var" "required checks failed")"; fi
exit "$HATA"
