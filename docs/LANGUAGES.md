# Languages

**English** · [Türkçe](DILLER.md)

Everything user-facing exists in English and Turkish: script messages, role prompts, the manager agent, the card skills, the docs, the trial project and the example cards.

## Choosing a language

| What | English (default) | Turkish |
|---|---|---|
| Persistent switch | `./sheepdog lang en` | `./sheepdog lang tr` |
| One command only | `SHEEPDOG_LANG=en ./board.sh` | `SHEEPDOG_LANG=tr ./board.sh` |
| Manager agent | `claude --agent sheepdog …` | `claude --agent sheepdog-tr …` |
| Card skill | `/job-card` | `/is-karti` |
| Role prompts | `roles/en/` | `roles/tr/` |
| Trial kit | `bash trial/setup.sh <dir>` | `bash trial/setup.sh <dir> --lang tr` |
| Example cards | `examples/en/` | `examples/tr/` |

The language is resolved in this order: `SHEEPDOG_LANG`, then the `.lang` file, then English.

## Mixing languages

Cards, states and roles are accepted in **either** language, even mixed in one hub. A card keeps the language it was written in: `state.sh` writes `Status: working` on an English card and the Turkish value on a Turkish card. The log (`.history`) and all internals use the English names.

| Card field (en) | Turkish alias |
|---|---|
| `Status:` | `Durum:` |
| `Type:` | `Tür:` |
| `Waits-for:` | `Bekliyor:` |
| `Project:` | `Proje:` |
| `Model:` | `Model:` |
| `Effort:` | `Efor:` |

| Type | Turkish alias |
|---|---|
| `code` | `kod` |
| `content` | `icerik` |

| State | Turkish alias |
|---|---|
| `draft` | `taslak` |
| `ready` | `hazir` |
| `working` | `calisiyor` |
| `review` | `inceleme` |
| `verify` | `dogrulama` |
| `merge-queue` | `birlesme-bekliyor` |
| `merging` | `birlesiyor` |
| `done` | `bitti` |
| `stuck` | `tikandi` |

| Role | Turkish alias |
|---|---|
| `worker` | `isci` |
| `reviewer` | `reviewer` |
| `verifier` | `dogrulayici` |
| `merger` | `birlestirici` |

Verdict files end with `RESULT: PASSED` / `RESULT: FAILED` (Turkish: `SONUÇ: GEÇTİ` / `SONUÇ: KALDI`); the dry run prints `CLEAN` / `CONFLICT` (Turkish: `TEMIZ` / `CAKISMA`). The manager understands both.

## Adding another language

1. Copy `roles/en/` to `roles/<code>/` and translate the four prompts.
2. Teach `lang.sh` (the `T` helper currently takes two languages) and `trial/setup.py` about it.
3. Copy `.claude/agents/sheepdog.md` and `.claude/skills/job-card/` with the translated text.
4. Translate the docs and add a smoke-test check.
