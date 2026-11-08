# 001: Fix the API bug on an empty page parameter

Status: draft
Type: code
Waits-for: none
Project: /path/to/your/project

## What to do
Study the `GET /orders` endpoint in `api/orders.py` and `tests/test_orders.py`. On the local test server reproduce the 500 error twice, before any change, with `curl -i 'http://127.0.0.1:8000/orders?page='`. Confirm the real root cause from the stack trace, for example the line that converts the empty value to a number; do not write an assumption down as a result. A missing or empty `page` should count as 1 and return 200. Positive integers must keep the existing paging behavior; `abc`, `0` and `-1` must return 400 with the existing error body. First write a red regression test for the empty value, then fix only the parameter validation.

## Do not touch
Only `api/orders.py` and `tests/test_orders.py` may change. Authentication, the database schema and other endpoints are out of scope. Do not read or change `.env` and key files. No push, no PR and no merging into the main branch.

## If you get stuck
Stop if you cannot reproduce the bug in two attempts, the test server will not start, or 30 minutes pass. Report the commands and the blocker to Sheepdog. If the existing API contract wants a different result for the empty value, ask the user through Sheepdog with the options "treat empty as 1 / reject with 400" and do not change the contract until answered.

## Definition of done
- [ ] `result.md` → `Reproduction`: the command, the 500 response and a secret-free stack trace for two runs of the same request; the `Root cause` heading explains file and line.
- [ ] `python -m pytest tests/test_orders.py -k empty_page -q` fails before the fix and passes after it. Both outputs and exit codes are in `result.md` → `Regression`.
- [ ] `python -m pytest tests/test_orders.py -q` exits 0. The cases missing, empty, 1, 2, abc, 0 and -1 are tested; command and output are in `result.md` → `Checks`.
- [ ] `result.md` → `Delivery`: the real starting commit, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` and `git diff <start-commit> HEAD --stat` with their outputs; the branch name, commit hash and worktree path are stated. Changes are in the allowed files only and committed on its own branch.
