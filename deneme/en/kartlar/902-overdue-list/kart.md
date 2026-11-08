# 902: List overdue open loans

Status: draft
Type: code
Waits-for: none
Project: {{PROJE}}

## What to do
Add the command `python3 -m library [--data records.json] overdue --date YYYY-MM-DD`: it lists only loans that have not been returned and whose due date is before the given date, in increasing loan-number order. Each row/record contains loan id, book code, book title, member, due date and the positive number of days late. BEFORE implementing the format, ask Sheepdog with SendMessage these options and wait for the user's answer: "How should the overdue output look? A) A table with a header, tab-separated; if empty, 'No overdue loans.' (recommended, readable in a terminal). B) A JSON array; if empty, []; fields id, book, title, member, due_date, days_late (can be piped into other tools)." Do not assume before the answer arrives; Sheepdog will relay the question to the user. Implement only the chosen format and record the decision in `sonuc.md`. Do the calculation in a new `library/listing.py` module; the existing return bug is out of scope for this card. If Python 3 is only installed as `python`, use that.

## Do not touch
Do not change `library/rules.py`, `library/store.py` or the existing test files. Limit the new behavior to `library/listing.py`, `library/__main__.py`, a new `tests/test_overdue.py` and the project `README.md`. Listing must not write to the data file. No new dependency, no push, no PR, no merging into the main branch.

## Definition of done
- [ ] `sonuc.md` contains the two-option decision question and the user's answer relayed by Sheepdog; the CLI produces only the chosen output format, and the README has a runnable example in that format.
- [ ] `python3 -m unittest tests.test_overdue` passes: for 2026-01-20 an open loan due 2026-01-15 is listed with 5 days; returned loans, loans due the same day and loans due in the future are excluded. Several records are verified in increasing id order with all six fields.
- [ ] The same test command verifies the chosen empty output, exit code 1 and a clear message on an invalid date, and, in a separate CLI process, that the data file's bytes are unchanged.
- [ ] `python3 -m unittest` passes; commands, exit codes and outputs, plus branch, commit and worktree path, are in `sonuc.md`.

## If you get stuck
If the answer about the output format does not arrive, hold the implementation and tell Sheepdog. If you need a change outside the scope, or the job passes 30 minutes, report the blocker; do not decide in the user's place.
