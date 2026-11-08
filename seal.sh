#!/bin/bash
# Tamper evidence for the evidence files (spends no model tokens).
# Every role writes its own file into the card folder, and every role can write there. Detecting a
# forged or silently edited verdict is therefore the next best thing to preventing it.
#
#   ./seal.sh pre   jobs/<card> <role>   before launching a role: its file must not exist, or must be an
#                                        earlier round that was sealed and is unchanged
#   ./seal.sh done  jobs/<card> <role>   after the role reported: record the file's SHA-256 in .seals
#   ./seal.sh check jobs/<card>          verify that every sealed file is still unchanged
#   ./seal.sh verdict jobs/<card> <role> exit 0 only if the role's file exists, is sealed and unchanged, and its last
#                                        line is RESULT: PASSED (or the Turkish SONUÇ: GEÇTİ); used by state.sh
#
# Roles and files: worker -> result.md, reviewer -> review.md, verifier -> verification.md, merger -> merge.md
# Exit 0 = fine, 1 = TAMPER / missing, 2 = usage error. The ledger .seals lives in the hub, outside the card folder.
cd "$(dirname "$0")"; . ./lang.sh
mode="$1"; K="${2%/}"; ROLE="$(nrole "${3:-}")"
[ -n "$mode" ] && [ -n "$K" ] || { echo "usage: seal.sh pre|done|check jobs/<card> [role]"; exit 2; }
[ -d "$K" ] || { echo "$(T "Kart yok" "No such card"): $K"; exit 2; }
CARD="$(basename "$K")"
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
file_of(){ case "$1" in worker) echo result.md;; reviewer) echo review.md;; verifier) echo verification.md;; merger) echo merge.md;; *) echo "";; esac; }
hash_of(){ "$PY" -c "import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read().replace(b'\r\n',b'\n')).hexdigest())" "$1"; }
last_hash(){ [ -f .seals ] && awk -v c="$CARD" -v f="$1" '$2==c && $4==f {h=$5} END{print h}' .seals; }
case "$mode" in
  pre)
    f="$(file_of "$ROLE")"; [ -n "$f" ] || { echo "usage: seal.sh pre jobs/<card> worker|reviewer|verifier|merger"; exit 2; }
    [ -f "$K/$f" ] || { echo "ok: $f not written yet"; exit 0; }
    old="$(last_hash "$f")"
    if [ -n "$old" ] && [ "$old" = "$(hash_of "$K/$f")" ]; then echo "ok: $f is an earlier, sealed round"; exit 0; fi
    echo "TAMPER: $K/$f already exists but was never sealed (or changed after sealing). A role that is not $ROLE may have written it."; exit 1 ;;
  done)
    f="$(file_of "$ROLE")"; [ -n "$f" ] || { echo "usage: seal.sh done jobs/<card> worker|reviewer|verifier|merger"; exit 2; }
    [ -f "$K/$f" ] || { echo "MISSING: $K/$f was not written"; exit 1; }
    printf '%s %s %s %s %s\n' "$(date +%s)" "$CARD" "$ROLE" "$f" "$(hash_of "$K/$f")" >> .seals
    echo "sealed: $CARD $f" ;;
  check)
    [ -f .seals ] || { echo "ok: nothing sealed yet"; exit 0; }
    bad=0
    for f in result.md review.md verification.md merge.md; do
      want="$(last_hash "$f")"; [ -n "$want" ] || continue
      if [ ! -f "$K/$f" ]; then echo "TAMPER: sealed file $f is gone"; bad=1
      elif [ "$(hash_of "$K/$f")" != "$want" ]; then echo "TAMPER: $f changed after it was sealed"; bad=1; fi
    done
    [ "$bad" = 0 ] && echo "ok: all sealed files unchanged"; exit "$bad" ;;
  verdict)
    f="$(file_of "$ROLE")"; [ -n "$f" ] || { echo "usage: seal.sh verdict jobs/<card> worker|reviewer|verifier|merger"; exit 2; }
    [ -f "$K/$f" ] || { echo "MISSING: $K/$f (the $ROLE stage has not run)"; exit 1; }
    want="$(last_hash "$f")"; [ -n "$want" ] || { echo "UNSEALED: $K/$f was never sealed"; exit 1; }
    [ "$(hash_of "$K/$f")" = "$want" ] || { echo "TAMPER: $f changed after it was sealed"; exit 1; }
    [ "$ROLE" = worker ] && exit 0
    last="$(tr -d '\r' < "$K/$f" | awk 'NF{l=$0} END{print l}')"
    case "$last" in *"RESULT: PASSED"*|*"SONUÇ: GEÇTİ"*) exit 0;; *) echo "NOT PASSED: last line of $f is: $last"; exit 1;; esac ;;
  *) echo "usage: seal.sh pre|done|check|verdict jobs/<card> [role]"; exit 2 ;;
esac
