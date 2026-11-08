# 007: Reduce repeated queries in the order list

Status: draft
Type: code
Waits-for: none
Project: /path/to/your/project

## What to do
Measure whether `list_orders` in `repositories/orders.py` runs a separate customer query for each order. Use local test data only. In `tests/test_orders_performance.py` set up fixed data with 100 customers and 1000 orders in total; fetch the first 100 orders including the customer name. Start the query counter after data preparation; do not include connection setup in the measurement. In the same environment run three warm-ups and ten measurements; record the time and SQL count of each run. Then remove the repeated queries with bulk loading or the existing ORM relationship loading. Filter, ordering, paging, customer name and returned records must not change. The measurement test should print the times and query counts; use the same command before and after.

## Do not touch
Only `repositories/orders.py` and the named performance test file may change. Schema, indexes, caching, the production database and infrastructure settings are out of scope. Do not read or change `.env` and key files. No push, no PR and no merging into the main branch.

## If you get stuck
Stop if the baseline measurement cannot show the problem, the measurements are unstable, or 60 minutes pass; send the raw numbers to Sheepdog. If an index/schema or a cache is needed, ask the user through Sheepdog with the options "separate index card / rethink the query design". Do not shrink the data size to reach the target.

## Definition of done
- [ ] The before/after outputs of `python -m pytest tests/test_orders_performance.py -q -s` are in `sonuc.md` → `Measurement`; the data counts, the database version, three warm-ups and ten measurements are stated separately.
- [ ] The SQL count for the first 100 orders is at most 3, and the median time of ten measurements dropped at least 30% from the baseline. The raw times, medians and the `(before-after)/before*100` calculation are in `sonuc.md` → `Comparison`; if the target is not met the job does not count as done.
- [ ] `python -m pytest tests/test_orders.py tests/test_orders_performance.py -q -s` exits 0; the command/output and tests asserting the same expected records, ordering and fields before and after are in `sonuc.md` → `Behavior`.
- [ ] `sonuc.md` → `Delivery`: the real starting commit, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` and `git diff <start-commit> HEAD --stat` with their outputs; the branch name, commit hash and worktree path are stated. Changes are in the allowed files only and committed on its own branch.
