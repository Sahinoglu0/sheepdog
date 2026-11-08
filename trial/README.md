# 10-minute trial

**English** · [Türkçe](README.tr.md)

Try Sheepdog dispatching work, asking you for a decision, independent review, tests, merging and a dependent card, without touching your own project. The kit contains a ready Python library project and three cards. Setup takes seconds; the total time of the sessions depends on model replies and your decision.

The kit's requirements must be ready: Bash (including macOS 3.2 and Windows Git Bash), git 2.38+, Python 3.8+ (`python3` or `python`), and a Claude Code that supports background sessions. The installer does not run Claude; once you start the trial, the agent sessions spend your account's usage limit.

## Setup and start

From the hub root, choose a new target separate from your own projects. Quote paths that contain spaces. For example a sibling folder of the hub:

```bash
bash trial/setup.sh "../library-trial"            # English project and cards (default)
bash trial/setup.sh "../library-trial-tr" --lang tr   # Turkish project and cards
```

The target is created if missing; if it exists it must be completely empty (hidden files included). The project is copied and a first commit is made on `main`. If you have no global git identity, `trial <deneme@example.invalid>` is written to this new repository only; global settings are not changed. The installer sets up cards 901, 902 and 903 as ready in the hub's `jobs/` folder and rewrites the project paths to absolute. If the target is not empty or one of the cards already exists it stops before writing anything. It deletes nothing. On an unexpected disk/git error a partial setup may remain; inspect the error output and the folders, the script does no automatic cleanup.

Follow the order the installer prints:

1. Open `claude` once in the target, accept the trust prompt, and exit the session.
2. Go back to the hub and run `claude --agent sheepdog --name sheepdog --permission-mode auto` (Turkish: `--agent sheepdog-tr`).
3. Say **"start the ready cards"**. If you have other ready cards in the hub, this may start them too; to run only the trial say **"start only 901-early-return-bug, 902-overdue-list and then 903-usage-note"**.
4. In the hub, watch the board in another terminal with `./sheepdog watch`.

If you want approval before merging, add "ask me before merging" to your start message (or run `./sheepdog policy ask` first).

## What do the cards show?

| Card | Step shown | Expected result |
|---|---|---|
| 901-early-return-bug | Reproducing a bug, a regression test, review and verification | Negative lateness on early return becomes zero; the tested fix enters main. |
| 902-overdue-list | Handing off to a separate worker and a user decision | Sheepdog asks the table/JSON options; the `overdue` command in the format you choose enters main. |
| 903-usage-note | A dependent content card and review | Starts when 902 is done; `jobs/903-usage-note/result.md` becomes the user note. No code merge. |

The first two cards can start independently and touch different files. Merges to the same project happen one after another. 903 looks ready at the start but is not in `./sheepdog ready` until 902 is done.

## At the start and at the end

A starting check in the target:

```bash
python3 -m unittest
python3 -m library lateness --due-date 2026-01-15 --return-date 2026-01-01
```

8 tests pass but the second command prints `Late: -14 days`. That is the deliberately left real bug; the starting tests do not cover an early return. The command creates no data file. If Python 3 exists only as `python` on Windows, use that in the commands.

When the trial is complete the board should show three cards `done`. In the target the same test command should pass with the new tests; the reproducing command should print `Late: 0 days` and `python3 -m library overdue --date 2026-01-20` should run. With no data you see `No overdue loans.` or `[]` depending on your choice. The card folders hold results and review evidence, and for code cards the verification and merge reports. `git log --oneline` shows the changes that entered main.

The trial repository, the cards and the workers' worktrees stay for you to inspect; nothing is deleted or pushed automatically. To retry, use a separate copy of the kit and a new empty target; existing cards are never overwritten.
