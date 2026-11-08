# 002: Download the filtered order list as CSV

Status: draft
Type: code
Waits-for: none
Project: /path/to/your/project

## What to do
Work on `api/orders.py` and `tests/test_orders_csv.py`. Add the endpoint `GET /orders.csv?status=completed` using the existing list query. Check it on the local test server with `curl -i 'http://127.0.0.1:8000/orders.csv?status=completed'`. The output must cover all orders that the current user can access and that match the filter; it must not be limited to the on-screen page. Column order `id,date,status,total_cents`, sorted by ascending `id`. Use UTF-8, comma separator, CRLF line endings and standard CSV escaping; money is integer cents. The response carries 200, `Content-Type: text/csv; charset=utf-8` and `Content-Disposition: attachment; filename="orders.csv"`. An empty list returns only the header. If a text cell starts with =, +, - or @, prefix it with a single quote. Add no dependency; use the standard CSV writer.

## Do not touch
Only the named endpoint and the CSV test file may change. The UI, schema, the existing JSON response and access rules are out of scope. Do not read or change `.env` and key files. No push, no PR and no merging into the main branch.

## If you get stuck
If producing every record is not safe with the current infrastructure, do not pick a design: send Sheepdog the options "streamed download / record limit / background file generation" with cost and user impact, and wait for the user's decision. If the current infrastructure is enough, continue. Stop and report the remaining work if the access filter is unclear or 60 minutes pass.

## Definition of done
- [ ] `python -m pytest tests/test_orders_csv.py -q` exits 0. Filter, ordering, headers, empty list and at least two pages of data are tested; command and output are in `result.md` → `CSV contract`.
- [ ] Test data with non-ASCII characters, commas, double quotes, line breaks and formula starters is read back with a CSV reader and the expected cell values are asserted. Evidence in `result.md` → `CSV escaping`.
- [ ] Another user's orders are not exported; an unauthenticated request gets the existing access error. The output of `python -m pytest tests/test_orders.py tests/test_orders_csv.py -q` with exit code 0 is in `result.md` → `Access and regression`.
- [ ] `result.md` → `Delivery`: the real starting commit, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` and `git diff <start-commit> HEAD --stat` with their outputs; the branch name, commit hash and worktree path are stated. Changes are in the allowed files only and committed on its own branch.
