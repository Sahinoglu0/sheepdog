#!/bin/bash
# How many times a card went to work (rounds), counted from .gecmis, not from an agent's memory.
# Kartın kaç kez çalışmaya alındığı (.gecmis kaydından). usage: ./tur.sh isler/001-is
cd "$(dirname "$0")"; A="$(basename "${1%/}")"
[ -f .gecmis ] || { echo 0; exit 0; }
awk -v a="$A" '$2==a && $3=="calisiyor"{n++} END{print n+0}' .gecmis
