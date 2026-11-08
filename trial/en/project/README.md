# Library

A small loan-tracking app on the Python 3.8+ standard library. Every book code is a single physical copy; the loan period is 14 days. No server or package install needed.
Run the commands in this folder (use `python` if only that name points to Python 3):

```bash
python3 -m unittest
python3 -m library --help
python3 -m library add K1 "The Little Prince"
python3 -m library lend K1 Ada --date 2026-01-01
python3 -m library return 1 --date 2026-01-18
```

The last command prints `Returned. Late: 3 days`. Records live in `library.json` by default; give `--data records.json` before the command for another file.
Dates are `YYYY-MM-DD`; the due day itself is not late.

## Starting state of the trial

> This section describes the project **before** the trial cards run. Once cards 901 and 902 are merged it is history: the lateness bug is fixed and the `overdue` command exists. Card 903's worker is expected to notice that and report it.

The 8 starting tests pass. They do not cover early returns, so they miss the real calculation bug below. See it with a single command that uses the same calculation as returning and creates no file:

```bash
python3 -m library lateness --due-date 2026-01-15 --return-date 2026-01-01
```

Today it prints `Late: -14 days`; the right answer is `Late: 0 days`. Card 901 fixes this with a regression test. There is no command yet to list overdue open loans; card 902 adds it. The two jobs can run separately: the calculation fix lives in `rules.py`, the new list feature in `__main__.py` and a new module.
