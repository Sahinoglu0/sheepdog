#!/bin/bash
# Prints a project's main branch name; no model cost.
# usage: ./main-branch.sh <project>. Order: origin/HEAD, main, master, the checked-out branch (last resort).
. "$(cd "$(dirname "$0")" && pwd)/lang.sh"
P="$1"; [ -n "$P" ] || { echo "usage: main-branch.sh <project>" >&2; exit 2; }
d="$(git -C "$P" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)"; d="${d#origin/}"
# never guess the checked-out branch first: it may be a feature branch. It is only a last resort.
cur="$(git -C "$P" symbolic-ref -q --short HEAD 2>/dev/null)"
for a in "$d" main master "$cur"; do
  [ -n "$a" ] && git -C "$P" rev-parse --verify -q "refs/heads/$a" >/dev/null && { echo "$a"; exit 0; }
done
echo "$(T "Ana dal bulunamadı" "Main branch not found"): $P" >&2; exit 1
