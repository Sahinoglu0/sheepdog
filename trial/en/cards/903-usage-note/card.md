# 903: Short usage note for the overdue list

Status: draft
Type: content
Waits-for: 902-overdue-list
Project: {{PROJE}}

## What to do
After 902 is done, read the latest README, `library/__main__.py` and `library/listing.py` on the project's main branch. Write a 150–250 word English usage note for users into the `result.md` file next to this card. Explain adding books, lending, listing overdue loans, the separate data file with `--data`, and the date format. Show the real output format that the user chose in 902. Verify the example output by running the commands against a temporary data file; do not leave test data inside the project. Card 901 is not something this card waits for; do not assume the return bug is fixed and make no claims about the return fix.

## Do not touch
Do not change project files or the main branch; write only `result.md` in this card's own folder. Do not change code, tests, the README, other cards or card states. No push, no PR, no merge.

## Definition of done
- [ ] `result.md` exists next to the card; the user note is 150–250 words (not counting command/output blocks and the separate evidence paragraph). It explains the data file and the date format.
- [ ] The note contains commands for adding a book, lending and listing overdue loans against the same temporary data file, with verified example output; the output matches the format chosen in 902.
- [ ] The note correctly says that returned books and books not yet overdue are not listed, and what you see on an empty result; the claims agree with the main branch code.
- [ ] In the separate evidence paragraph at the end of `result.md`: the source paths read, the main branch commit, the exit codes of the commands run, and `git status --porcelain` before and after; no project file was changed.

## If you get stuck
If 902's merged feature is not on the main branch, the code and README disagree, or you cannot verify the commands, stop and report the concrete blocker to Sheepdog; do not invent output.
