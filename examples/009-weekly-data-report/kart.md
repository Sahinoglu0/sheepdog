# 009: Produce a verifiable weekly summary from the orders CSV

Status: draft
Type: content
Waits-for: none
Project: /path/to/your/notes

## What to do
Produce `reports/weekly-summary.md` from `data/orders.csv`. The input is UTF-8, comma-separated, with the columns `order_id,date,status,amount_cents`; each row is one order and the date is a timezone-less `YYYY-MM-DD` local calendar day. The report week is 2026-10-26 inclusive to 2026-11-02 exclusive. For `completed` orders compute the count and the total amount in cents, the per-day breakdown, and the average rounded half-up to the nearest cent. Exclude `cancelled` records from revenue and show their count separately. Audit the whole file for duplicate order ids, missing fields, invalid dates or statuses, and negative or non-integer cent values; never skip a row silently. Write the calculation in `reports/weekly_calc.py` using only the standard library. Check that the daily totals match the weekly total, and verify the weekly total with an independent second pass that does not use the daily grouping. Record the input hash; add no personal data or raw rows to the report.

## Do not touch
Only `reports/weekly-summary.md`, `reports/weekly_calc.py` and the `sonuc.md` next to the card may be written. The source CSV is read-only; other weeks and accounting records are out of scope. Do not read or change `.env` and key files. Do not upload the data to an outside service.

## If you get stuck
Stop if the schema differs, there are broken or duplicate rows, or 45 minutes pass. Report row numbers and issue counts to Sheepdog without exposing identifiers. Pass the options "wait for corrected input / count the problem rows separately and narrow the scope" on for the user to answer; do not present the report as complete before a decision.

## Definition of done
- [ ] `python3 reports/weekly_calc.py data/orders.csv --start 2026-10-26 --end 2026-11-02` exits 0; the command and output are in `sonuc.md` → `Calculation`. The script contract accepts these arguments; the input SHA-256 is under the same heading.
- [ ] `sonuc.md` → `Row audit`: total rows, in-week and out-of-week rows, completed and cancelled counts; the number of invalid and duplicate records is 0. The equalities total rows = in-week + out-of-week and in-week = completed + cancelled are shown with numbers.
- [ ] `sonuc.md` → `Cross-check`: the sum of the daily amounts, the direct weekly total and the second-pass result are equal in cents. The total/count calculation for the average and the rounding are written; if the count is 0 the average is shown as "not computable".
- [ ] `reports/weekly-summary.md` has the date range, a statement that the currency unit is cents, the seven-day table and the cancelled count; every number is matched with the script output. The matching is in `sonuc.md` → `Report audit`.
- [ ] In `sonuc.md` → `Delivery` next to the card: paths of the produced files, the verification commands that were run, their outputs and exit codes; the worker did not change the card state.
