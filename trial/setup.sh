#!/bin/bash
# usage: bash trial/setup.sh <new-or-empty-target-folder> [--lang en|tr]
set -e
export PYTHONUTF8=1
TRIAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
exec "$PY" "$TRIAL/setup.py" "$@"
