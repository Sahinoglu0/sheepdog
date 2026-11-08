# Usage guide

**English** · [Türkçe](USAGE.tr.md)

Run commands from the kit's root (the "hub"). Replace `<project>` and `<card>` with your own paths and card folder names. Put **absolute** paths in a card's `Project:` field. On Windows use Git Bash. `./sheepdog help` lists every front-door command.

## Before you start

1. `./sheepdog doctor /abs/path/project` checks Claude Code (2.1.293+, `--bg`, `agents`), git 2.38+, Python 3.8+ and the trust prompt.
2. Open `claude` once in every target project and accept the trust dialog. In a git repo, a parent folder's approval is not enough.
3. Write cards in a normal Claude Code session in the hub: `/job-card <the job>`. Answer its questions, then read `jobs/<card>/card.md`. Check `Project`, `Type`, `Waits-for`, the scope and the measurable definition of done. Or scaffold a draft yourself: `./sheepdog new fix-login --project /abs/path/app`.
4. Approve with `./sheepdog set <card> ready`, then start Sheepdog:

   ```bash
   claude --agent sheepdog --name sheepdog --permission-mode auto
   ```

   and say **"start the ready cards"**. Run one Sheepdog per machine: workers message the session named `sheepdog`.

Code cards flow worker → reviewer → verifier → dry run → merger. Content cards finish after review. Watch from another terminal with `./sheepdog watch`. Sheepdog stays quiet while things run; it speaks up for a decision, a finished card, or a stuck one.

## 1. First trial

```bash
bash trial/setup.sh ../library-trial
```

Open `claude` once in the new project, run `./sheepdog doctor ../library-trial`, start Sheepdog and say *"Ask me before merging. Start the ready cards."* Watch with `./sheepdog watch`.

**Expected:** the card goes `working`, then through the checks; you are asked before the merge, and afterwards told which branch entered main at which commit. The card folder holds `result.md`, `review.md`, `verification.md` and `merge.md`.

**Note:** the trial opens real model sessions and spends your usage limit.

## 2. Several bug fixes in one project

Ask in a normal session: *"/job-card in /abs/path/app: the sign-up form crashes on an empty e-mail; search shows the old list on an empty result. Prepare separately finishable cards."* Keep "Do not touch" narrow. If one change depends on another, put the earlier card's folder name in the later one's `Waits-for:` (comma-separated for several). Approve each card, then start Sheepdog.

**Expected:** independent jobs run in separate worker sessions on separate worktree branches. One merger at a time per project; a conflict at merge time sends the job back to its worker.

Add `.claude/worktrees/` to the project's `.gitignore`. The kit never pushes; sending the merged main upstream is your decision.

## 3. Unrelated jobs in different projects

```bash
./sheepdog doctor /abs/path/project-a /abs/path/project-b
```

Write separate requests (a code fix in A, a research report for B), check `Type: code` versus `Type: content`, approve both, start Sheepdog once. Cards start in their own `Project:` folders. Each session spends its own usage; don't run a second Sheepdog.

## 4. Research → decision memo → implementation

Chain three cards:

| Card | Type | Waits-for |
|---|---|---|
| `001-research` | `content` | `none` |
| `002-decision-memo` | `content` | `001-research` |
| `003-implementation` | `code` | `002-decision-memo` |

`./sheepdog ready` initially shows only the research card; after each `done`, Sheepdog starts the next unblocked one. If you want to make the final choice yourself, leave the implementation card `draft`, read the memo, then `./sheepdog set 003-implementation ready`. `Waits-for:` waits for `done`; it is not a substitute for your approval.

## 5. Cautious mode: ask before merging

Make it persistent, so a new Sheepdog session still honors it:

```bash
./sheepdog policy ask      # every merge needs your approval
./sheepdog policy auto     # default
```

While the policy is `ask`, `launch.sh ... merger` and `state.sh ... merging` are refused until you answer yes in the chat and Sheepdog records it with `./sheepdog approve <card>`. You can also run that command yourself.

When asked, read `result.md`, `review.md` and `verification.md`, check the diff, then say *"approve the merge for 001"* or *"don't merge 001 yet; wait for my decision"*. Content cards never reach the merge step.

## 6. Leaving it running for hours

1. Check cards, trust prompts and `./sheepdog doctor`. Settle decisions up front.
2. Sheepdog starts `watchdog.sh` after the first session. It looks every 600 s with a 20-minute silence limit, reports a problem and exits; Sheepdog restarts it while work remains. One failed `claude agents` call is ignored; three in a row are reported.
3. Run `./sheepdog watch` in another terminal (Ctrl+C closes only the board).
4. In the morning ask *"status?"*, run `./sheepdog board`, look at `stuck` and `merge-queue` cards, and use `./sheepdog timeline` to see where time went. For merged code cards, read `merge.md`.

The computer and sessions must stay on. The watchdog does not restart work, and the board does not prove a session is healthy.

## 7. A stuck or returned job

Run `./sheepdog board`, then ask *"what is 007 stuck on?"* and read its evidence files. A failed review or verification sends findings to the same worker (state `working`); `./sheepdog rounds 007-x` shows how many times. After three, Sheepdog asks you. Answer concretely: *"forward to 007's worker: the bug only appears on an empty query; expected result is an empty list; reproduce with …"*.

If a merge failed because of the environment the card becomes `stuck`. Fix the environment, then say *"007's environment problem is fixed; re-check the evidence and session state"*. Never mark a card `done` by hand to skip the checks.

There is no "stop this card" flow yet; setting a card to `draft` does not stop a running session.

## Which role uses which model

| Role | Job | Default | Effort |
|---|---|---|---|
| worker | does the card, writes evidence | sonnet | medium |
| reviewer | independent acceptance review | sonnet | medium |
| verifier | runs the written checks | haiku | medium |
| merger | tests the merged tree, lands it | sonnet | medium |
| Sheepdog | sessions and decisions | sonnet | medium |
| watchdog, board, dry run | no model | none | none |

Choose a profile in `settings.sh`:

```bash
PROFILE=frugal   # default; or balanced or strong
```

| Profile | worker | reviewer | verifier | merger |
|---|---|---|---|---|
| frugal | sonnet, medium | sonnet, medium | haiku, medium | sonnet, medium |
| balanced | sonnet, high | sonnet, high | sonnet, medium | sonnet, high |
| strong | opus, high | opus, high | sonnet, high | opus, high |

Profiles are unmeasured suggestions, not guarantees. Override one role by uncommenting a line in `settings.sh` (for example `MODEL_WORKER=opus`); override one card's worker with `Model: opus` / `Effort: high` in the card (priority: card → `settings.sh` → built-in defaults). Effort must be `low`, `medium` or `high`; model and effort are validated before a session starts. Changes apply to newly started sessions only. For Sheepdog itself edit `model:` and `effort:` in `.claude/agents/sheepdog.md`.

Preview without opening a session:

```bash
SHEEPDOG_DRY=1 ./launch.sh jobs/<card> worker
```

## Short phrases for Sheepdog

- "Start the ready cards." / "Status?"
- "Ask me before merging." / "Merge automatically."
- "Approve the merge for 001." / "Don't merge 001 yet."
- "Forward to 007's worker: …"
- "For 007, I choose the second option."
