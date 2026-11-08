# 901: Negative lateness on early return

Status: draft
Type: code
Waits-for: none
Project: {{PROJE}}

## What to do
In the project root, reproduce the bug twice with `python3 -m library lateness --due-date 2026-01-15 --return-date 2026-01-01`: the starting output is `Late: -14 days`, the expected output is `Late: 0 days`. Find and fix the root cause in the lateness calculation that the return flow also uses. Returning early or on the loan day must give zero lateness, returning on the due day gives zero, and later returns give the real positive number of days. Returning before the loan date must still be rejected. First add the new regression test and show that it fails on the current code; then fix the code and prove the test passes. If Python 3 is only installed as `python`, use that name in the commands.

## Do not touch
Work only in `library/rules.py` and the new file `tests/test_return_regression.py`. Do not loosen existing tests. Do not change the listing feature, the CLI format or the data schema. No push, no PR, no merging into the main branch.

## Definition of done
- [ ] The reproduction command prints `Late: -14 days` twice before the fix and `Late: 0 days` after it; the commands, exit codes and outputs are in the card's `sonuc.md`.
- [ ] `python3 -m unittest tests.test_return_regression` fails before the fix and passes after it; both outputs are in `sonuc.md`. The tests exercise the real `take_back` flow for same-day, early, due-day and late returns and the rejection of a return before the loan date.
- [ ] `python3 -m unittest` passes with all tests; the command and output are in `sonuc.md`.
- [ ] Branch, commit and worktree path are in `sonuc.md`; the diff changes only the two allowed files.

## If you get stuck
If you cannot reproduce the bug, need a change outside the scope, or the job passes 30 minutes, stop and report the concrete blocker to Sheepdog.
