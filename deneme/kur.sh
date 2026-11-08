#!/bin/bash
# kullanım: bash deneme/kur.sh <yeni-veya-boş-hedef-klasör>
set -e
export PYTHONUTF8=1
DENEME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
exec "$PY" "$DENEME/kur.py" "$@"
