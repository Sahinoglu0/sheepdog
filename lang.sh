# Language + alias helpers, sourced by the other scripts.
# Language: $SHEEPDOG_LANG (en|tr), else the file .lang, else en.  "./sheepdog lang tr" makes it persistent.
_SD_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "${SHEEPDOG_LANG:-}" ]; then SHEEPDOG_LANG="$(cat "$_SD_HOME/.lang" 2>/dev/null | head -1)"; fi
case "$SHEEPDOG_LANG" in tr) ;; *) SHEEPDOG_LANG=en;; esac
export SHEEPDOG_LANG
# T "turkce" "english": prints the text in the active language
T(){ if [ "$SHEEPDOG_LANG" = tr ]; then printf '%s' "$1"; else printf '%s' "$2"; fi; }
# Card fields accept both Turkish and English keys.
_alias(){ case "$1" in
  Durum|Status) echo 'Durum|Status';; "Tür"|Type) echo 'Tür|Type';; Bekliyor|Waits-for) echo 'Bekliyor|Waits-for';;
  Proje|Project) echo 'Proje|Project';; Model) echo 'Model';; Efor|Effort) echo 'Efor|Effort';; *) echo "$1";; esac; }
# field <Key> <file>: value of the first matching field (either language)
field(){ local a; a="$(_alias "$1")"; sed -n -E "s/^($a): //p" "$2" | head -1; }
# nstate: any state name (en or tr) -> canonical English name used on disk and in logs
nstate(){ case "$1" in
  taslak) echo draft;; hazir) echo ready;; calisiyor) echo working;; inceleme) echo review;; dogrulama) echo verify;;
  birlesme-bekliyor) echo merge-queue;; birlesiyor) echo merging;; bitti) echo done;; tikandi) echo stuck;; *) echo "$1";; esac; }
# tstate: canonical English state -> Turkish
tstate(){ case "$1" in
  draft) echo taslak;; ready) echo hazir;; working) echo calisiyor;; review) echo inceleme;; verify) echo dogrulama;;
  merge-queue) echo birlesme-bekliyor;; merging) echo birlesiyor;; done) echo bitti;; stuck) echo tikandi;; *) echo "$1";; esac; }
# dstate: canonical state shown in the active language
dstate(){ if [ "$SHEEPDOG_LANG" = tr ]; then tstate "$1"; else echo "$1"; fi; }
# ntype: any type name -> canonical English (code|content)
ntype(){ case "$1" in kod) echo code;; icerik) echo content;; *) echo "$1";; esac; }
# nrole: role alias (en or tr) -> canonical role id (worker|reviewer|verifier|merger)
nrole(){ case "$1" in isci) echo worker;; dogrulayici) echo verifier;; birlestirici) echo merger;; *) echo "$1";; esac; }
