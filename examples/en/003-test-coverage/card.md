# 003: Test the discount calculator's current behavior

Status: draft
Type: code
Waits-for: none
Project: /path/to/your/project

## What to do
Study the untested function `calculate_discount(amount_cents, rate, cap_cents)` in `services/discount.py`. Write tests that pin the current behavior, only in `tests/test_discount.py`. Cover normal rate, zero amount, zero rate, below/at/above the cap, the rounding boundary, negative input and invalid types. Derive the expected values from the existing code and its call sites; do not compute them by copying the same algorithm into the test. For every boundary use a concrete input and a fixed expected value or exception type. Take a measurement with `python -m pytest --cov=services.discount --cov-branch --cov-report=term-missing -q` before and after. If a test tool is missing, report the blocker without adding a dependency.

## Do not touch
Only `tests/test_discount.py` may change. Production code, test configuration, dependency files and other modules are out of scope. Do not read or change `.env` and key files. No push, no PR and no merging into the main branch.

## If you get stuck
If the current behavior contradicts the documentation, do not fix anything: send Sheepdog the options "document the current behavior in the test / open a separate bug card" and wait for the user's decision. Stop and report the ambiguous input and the observed output if you cannot determine the expected result or 45 minutes pass.

## Definition of done
- [ ] `result.md` → `Behavior table` lists the input, fixed expected result and test name of the nine cases above; exception cases are clearly separated.
- [ ] `python -m pytest --cov=services.discount --cov-branch --cov-report=term-missing -q` exits 0; the module's line and branch coverage are at least 90%. The before/after numbers and the full output are in `result.md` → `Coverage`.
- [ ] `python -m pytest -q` exits 0; command and output are in `result.md` → `Regression`. `git diff --name-only <start-commit> HEAD` shows only the allowed test file; the real starting hash and output are under `Scope limit`.
- [ ] `result.md` → `Delivery`: the real starting commit, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` and `git diff <start-commit> HEAD --stat` with their outputs; the branch name, commit hash and worktree path are stated. Changes are in the allowed files only and committed on its own branch.
