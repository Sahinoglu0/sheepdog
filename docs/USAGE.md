# Usage guide

Run commands from the kit's root (the "hub"). Replace `<project>` and `<card>` with your own paths and card folder names. Put **absolute** paths in a card's `Proje:` field. On Windows use Git Bash.

`./sheepdog help` lists the English front-door commands; [GLOSSARY.md](GLOSSARY.md) maps every Turkish name.

## Before you start

1. `./sheepdog doctor /abs/path/project` checks Claude Code (2.1.293+, `--bg`, `agents`), git 2.38+, Python 3.8+, and the trust prompt.
2. Open `claude` once in every target project and accept the trust dialog. In a git repo, a parent folder's approval is not enough.
3. Write cards in a normal Claude Code session in the hub: `/is-karti <the job>`. Answer its questions, then read `isler/<card>/kart.md`. Check `Proje`, `Tür`, `Bekliyor`, scope and the measurable "done" criteria. Or scaffold a draft yourself: `./sheepdog new fix-login --project /abs/path/app`.
4. Approve with `./sheepdog set <card> hazir`, then start Sheepdog:

   ```bash
   claude --agent sheepdog --name sheepdog --permission-mode auto
   ```

   and say **"start the ready cards"**. One Sheepdog per machine: workers message the session named `sheepdog`.

Code cards flow worker → reviewer → verifier → dry run → merger. Content cards finish after review. Watch from another terminal with `./sheepdog watch`. Sheepdog stays quiet while things run; it speaks up for a decision, a finished card, or a stuck one.

## 1. First trial

Build the trial project and its cards, open Claude once in the new project, then run `./sheepdog doctor <project>`. Start Sheepdog and say *"Ask me before merging. Start the ready cards."* Watch with `./sheepdog watch`.

```bash
bash deneme/kur.sh ../library-trial
```

**Expected:** the card goes `calisiyor`, then through the checks; you are asked before the merge, and afterwards told which branch entered main at which commit. The card folder holds `sonuc.md`, `inceleme.md`, `dogrulama.md` and `birlesme.md`.

**Note:** the trial opens real model sessions and spends your usage limit.

## 2. Several bug fixes in one project

Ask in a normal session: *"/is-karti in /abs/path/app: the sign-up form crashes on an empty e-mail; search shows the old list on an empty result. Prepare separately finishable cards."* Keep "Neye dokunma" narrow. If one change depends on another, put the earlier card's folder name in the later one's `Bekliyor:` (comma-separated for several). Approve each card, then start Sheepdog.

**Expected:** independent jobs run in separate worker sessions on separate worktree branches. One merger at a time per project; a conflict at merge time sends the job back to its worker.

Add `.claude/worktrees/` to the project's `.gitignore`. The kit never pushes; sending the merged main upstream is your decision.

## 3. Unrelated jobs in different projects

```bash
./sheepdog doctor /abs/path/project-a /abs/path/project-b
```

Write separate requests (a code fix in A, a research report for B), check `Tür: kod` vs `Tür: icerik`, approve both, start Sheepdog once. Cards start in their own `Proje:` folders. Each session spends its own usage; don't run a second Sheepdog.

## 4. Research → decision memo → implementation

Chain three cards:

| Card | Tür | Bekliyor |
|---|---|---|
| `001-research` | `icerik` | `yok` |
| `002-decision-memo` | `icerik` | `001-research` |
| `003-implementation` | `kod` | `002-decision-memo` |

`./sheepdog ready` initially shows only the research card; after each `bitti`, Sheepdog starts the next unblocked one. If you want to make the final choice yourself, leave the implementation card `taslak`, read the memo, then `./sheepdog set 003-implementation hazir`. `Bekliyor:` waits for `bitti`; it is not a substitute for your approval.

## 5. Cautious mode: ask before merging

Make it persistent, so a new Sheepdog session still honors it:

```bash
./sheepdog policy ask      # every merge needs your approval
./sheepdog policy auto     # default
```

When asked, read `sonuc.md`, `inceleme.md`, `dogrulama.md`, check the diff, then say *"approve the merge for 001"* or *"don't merge 001 yet; wait for my decision"*. Content cards never reach the merge step.

## 6. Leaving it running for hours

1. Check cards, trust prompts and `./sheepdog doctor`. Settle decisions up front.
2. Sheepdog starts `gozcu.sh` after the first session. It looks every 600 s with a 20 min silence limit, reports a problem and exits; Sheepdog restarts it while work remains. One failed `claude agents` call is ignored; three in a row are reported.
3. `./sheepdog watch` in another terminal (Ctrl+C closes only the board).
4. In the morning ask *"status?"*, run `./sheepdog board`, look at `tikandi` and `birlesme-bekliyor` cards, and `./sheepdog timeline` for where time went. For merged code cards, read `birlesme.md`.

The computer and sessions must stay on. The watchdog does not restart work, and the board does not prove a session is healthy.

## 7. A stuck or returned job

`./sheepdog board`, then ask *"what is 007 stuck on?"* and read its evidence files. A failed review or verification sends findings to the same worker (state `calisiyor`); `./sheepdog rounds 007-x` shows how many times. After three, Sheepdog asks you. Answer concretely: *"forward to 007's worker: the bug only appears on an empty query; expected result is an empty list; reproduce with …"*.

If a merge failed because of the environment the card becomes `tikandi`. Fix the environment, then say *"007's environment problem is fixed; re-check the evidence and session state"*. Don't mark a card `bitti` by hand to skip the checks.

There is no "stop this card" flow yet; setting a card to `taslak` does not stop a running session.

## Which role uses which model

| Role | Job | Default | Effort |
|---|---|---|---|
| worker (`isci`) | does the card, writes evidence | sonnet | high |
| reviewer | independent acceptance review | sonnet | high |
| verifier (`dogrulayici`) | runs the written checks | sonnet | medium |
| merger (`birlestirici`) | tests the merged tree, lands it | sonnet | high |
| Sheepdog | sessions and decisions | opus | high |
| watchdog, board, dry run | no model | none | none |

Choose a profile in `ayarlar.sh`:

```bash
PROFIL=ekonomik   # or dengeli (default) or guclu
```

| Profile | worker | reviewer | verifier | merger |
|---|---|---|---|---|
| ekonomik (frugal) | sonnet, medium | sonnet, medium | haiku, medium | sonnet, medium |
| dengeli (balanced) | sonnet, high | sonnet, high | sonnet, medium | sonnet, high |
| guclu (strong) | opus, high | opus, high | sonnet, high | opus, high |

Profiles are unmeasured suggestions, not guarantees. Override one role by uncommenting a line in `ayarlar.sh` (e.g. `MODEL_ISCI=opus`); override one card's worker with `Model: opus` / `Efor: high` in the card (priority: card → `ayarlar.sh` → built-in defaults). Effort must be `low`, `medium` or `high`; model and effort are validated before a session starts. Changes apply to newly started sessions only. For Sheepdog itself edit `model:`/`effort:` in `.claude/agents/sheepdog.md`.

Preview without opening a session:

```bash
SHEEPDOG_KURU=1 ./baslat.sh isler/<card> isci
```

## Short phrases for Sheepdog

- "Start the ready cards." / "Status?"
- "Ask me before merging." / "Merge automatically."
- "Approve the merge for 001." / "Don't merge 001 yet."
- "Forward to 007's worker: …"
- "For 007, I choose the second option."
