#!/bin/bash
# How many times a card went to work (rounds), counted from .history, not from an agent's memory.
# usage: ./rounds.sh jobs/001-task
cd "$(dirname "$0")"; A="$(basename "${1%/}")"
[ -f .history ] || { echo 0; exit 0; }
awk -v a="$A" '$2==a && ($3=="working" || $3=="calisiyor"){n++} END{print n+0}' .history
