#!/bin/bash
# The only place that changes a card's state. Accepts English or Turkish state names.
# usage: ./state.sh jobs/001-task <state>
cd "$(dirname "$0")"; . ./lang.sh; K="${1%/}"; Y="$(nstate "$2")"
case "$Y" in draft|ready|working|review|verify|merge-queue|merging|done|stuck) ;; *) echo "$(T "Geçersiz durum" "Invalid state"): $2"; exit 1;; esac
[ -f "$K/card.md" ] || { echo "$(T "Kart yok" "No such card"): $K"; exit 1; }
# the card keeps its own language: "Status:" cards get English values, "Durum:" cards Turkish ones
if grep -q '^Status: ' "$K/card.md"; then KEY=Status; VAL="$Y"; else KEY=Durum; VAL="$(tstate "$Y")"; fi
T="$K/.card.$$"; awk -v key="$KEY" -v val="$VAL" '!d && /^(Durum|Status): /{ cr=($0 ~ /\r$/)?"\r":""; print key ": " val cr; d=1; next } {print}' "$K/card.md" > "$T" && mv "$T" "$K/card.md"
printf '%s %s %s\n' "$(date +%s)" "$(basename "$K")" "$Y" >> .history
echo "$(basename "$K"): $(dstate "$Y")"
