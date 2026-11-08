# 005: Split the order-total function while preserving behavior

Status: draft
Type: code
Waits-for: none
Project: /path/to/your/project

## What to do
Study the long `order_total` function in `services/order.py`. First pin the current outputs in `tests/test_order_total.py` for an empty basket, one/many items, discount, tax, both sides of the shipping threshold and the rounding boundary. Test the externally observable total and exceptions, not intermediate values. Run the tests before any change and put them in a separate commit. Then, in the same module, extract the item total, discount and shipping calculation into private helper functions. The outer function's signature, calculation order, rounding and error behavior must stay exactly the same. Reduce the function to at most 40 logical lines, not counting blank lines and comments. Add no new architecture or dependency.

## Do not touch
Only `services/order.py` and the named test file may change. Pricing rules, the database, the API and other modules are out of scope. Do not read or change `.env` and key files. No push, no PR and no merging into the main branch.

## If you get stuck
If you see a bug in the behavior, do not fix it in this card: send Sheepdog the options "keep the current behavior / open a separate bug card" and wait for the user's decision. Stop and report the concrete blocker if there is a side effect you cannot test, a need to move code into another module, or the 60-minute limit.

## Definition of done
- [ ] `python -m pytest tests/test_order_total.py -q` exits 0 before and after the refactor. Both outputs, the same test scenarios and the earlier test commit are in `result.md` → `Behavior pinning`.
- [ ] `result.md` → `Structural diff`: the outer signature before/after, the job of each extracted helper, and a numbered source listing showing the main function is at most 40 logical lines.
- [ ] `python -m pytest -q` exits 0; command and output are in `result.md` → `Regression`. The output of `git diff <test-commit> HEAD -- tests/test_order_total.py` is empty; the real test commit and output are under the same heading.
- [ ] `result.md` → `Delivery`: the real starting commit, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` and `git diff <start-commit> HEAD --stat` with their outputs; the branch name, commit hash and worktree path are stated. Changes are in the allowed files only and committed on its own branch.
