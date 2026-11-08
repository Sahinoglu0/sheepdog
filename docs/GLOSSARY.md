# Glossary

The kit was first written in Turkish. Behavior is language-independent; this table maps every Turkish name to its meaning. An English-named interface is on the roadmap. Until then, `./sheepdog` is the English front door for the commands below.

## Language

Everything user-facing exists in English and Turkish. `./sheepdog lang en|tr` (or `SHEEPDOG_LANG`) picks the language of script messages, role prompts and the `new` card template; the agents are `sheepdog` (en) and `sheepdog-tr` (tr); the card skills are `/job-card` (en) and `/is-karti` (tr). Card fields, state names and role names are accepted in **either** language, even mixed in one hub; on disk, logs use the Turkish canonical state names.

## Roles

| Name | Meaning | Role file |
|---|---|---|
| `isci` (alias `worker`) | worker | `roller/<lang>/isci.md` |
| `reviewer` | independent reviewer | `roller/<lang>/reviewer.md` |
| `dogrulayici` (alias `verifier`) | verifier | `roller/<lang>/dogrulayici.md` |
| `birlestirici` (alias `merger`) | merger | `roller/<lang>/birlestirici.md` |

## Card states (`Durum:`)

| State (tr) | English alias | Meaning |
|---|---|---|
| `taslak` | `draft` | draft: written, not approved |
| `hazir` | `ready` | ready: you approved it, can start |
| `calisiyor` | `working` | working: a worker is on it |
| `inceleme` | `review` | review: the reviewer is checking |
| `dogrulama` | `verify` | verify: the verifier is running checks (code cards) |
| `birlesme-bekliyor` | `merge-queue` | merge queue: dry run was clean, waiting for its turn (or your approval) |
| `birlesiyor` | `merging` | merging: the merger is on it |
| `bitti` | `done` | done |
| `tikandi` | `stuck` | stuck: needs a human or an environment fix |

## Card fields

| Field | Meaning |
|---|---|
| `Durum:` / `Status:` | state |
| `Tür:` / `Type:` | `kod`/`code` (gets verify + merge) or `icerik`/`content` (review only) |
| `Bekliyor:` / `Waits-for:` | `yok`/`none` or comma-separated card folder names |
| `Proje:` / `Project:` | absolute path of the project the job runs in |
| `Model:`, `Efor:`/`Effort:` | optional per-card worker model / effort override |
| `Ne yapılacak` | what to do |
| `Neye dokunma` | do not touch |
| `Bitti demek` | definition of done |
| `Takılırsan` | if you get stuck |

## Files and commands

| Name | Meaning |
|---|---|
| `isler/` | jobs: one folder per card (not committed) |
| `sonuc.md` | worker's result and evidence |
| `inceleme.md` | reviewer's verdict |
| `dogrulama.md` | verifier's verdict |
| `birlesme.md` | merger's record |
| `SONUÇ: GEÇTİ` / `SONUÇ: KALDI` | RESULT: PASSED / FAILED (last line of each verdict file) |
| `.gecmis` | history: append-only log of state changes (`epoch card state`) |
| `.politika` | persistent merge policy (`ask` or `auto`) |
| `pano.sh` | board |
| `gozcu.sh` | watchdog |
| `durum.sh` | set state |
| `baslat.sh` | start a session |
| `birlestirme-hazirla.sh` | merge dry run |
| `kontrol.sh` | doctor / environment check |
| `ayarlar.sh` | settings (model profiles) |
| `ana-dal.sh` | main-branch detection |
| `tur.sh` | round counter |
| `/is-karti`, `/job-card` | card-writing skill (tr, en) |
| `dil.sh`, `.dil` | language helpers, persistent language |
| `deneme/` | trial kit |
| `ornek-kartlar/` | example cards |

## `./sheepdog` command map

| English | Runs |
|---|---|
| `board`, `status` | `pano.sh` |
| `watch` | `pano.sh --izle` |
| `ready` | `pano.sh --baslayabilir` |
| `start <card> [role]` | `baslat.sh` |
| `set <card> <state>` | `durum.sh` |
| `rounds <card>` | `tur.sh` |
| `timeline [card]` | built in |
| `policy [ask\|auto]` | built in |
| `new <slug> --project P` | built in |
| `lang [en\|tr]` | built in |
| `doctor` | `kontrol.sh` |
| `main-branch` | `ana-dal.sh` |
| `dry-run` | `birlestirme-hazirla.sh` |
