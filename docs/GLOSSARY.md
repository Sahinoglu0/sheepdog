# Glossary

The kit was first written in Turkish. Behavior is language-independent; this table maps every Turkish name to its meaning. An English-named interface is on the roadmap. Until then, `./sheepdog` is the English front door for the commands below.

## Roles

| Name | Meaning | Role file |
|---|---|---|
| `isci` | worker | `roller/isci.md` |
| `reviewer` | independent reviewer | `roller/reviewer.md` |
| `dogrulayici` | verifier | `roller/dogrulayici.md` |
| `birlestirici` | merger | `roller/birlestirici.md` |

## Card states (`Durum:`)

| State | Meaning |
|---|---|
| `taslak` | draft: written, not approved |
| `hazir` | ready: you approved it, can start |
| `calisiyor` | working: a worker is on it |
| `inceleme` | review: the reviewer is checking |
| `dogrulama` | verify: the verifier is running checks (code cards) |
| `birlesme-bekliyor` | merge queue: dry run was clean, waiting for its turn (or your approval) |
| `birlesiyor` | merging: the merger is on it |
| `bitti` | done |
| `tikandi` | stuck: needs a human or an environment fix |

## Card fields

| Field | Meaning |
|---|---|
| `Durum:` | state |
| `Tür:` | type: `kod` (code, gets verify + merge) or `icerik` (content, review only) |
| `Bekliyor:` | waits for: `yok` (none) or comma-separated card folder names |
| `Proje:` | absolute path of the project the job runs in |
| `Model:`, `Efor:` | optional per-card worker model / effort override |
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
| `/is-karti` | "job card" skill |
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
| `doctor` | `kontrol.sh` |
| `main-branch` | `ana-dal.sh` |
| `dry-run` | `birlestirme-hazirla.sh` |
