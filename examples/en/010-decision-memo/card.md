# 010: Turn the research into a short decision memo

Status: draft
Type: content
Waits-for: 008-sourced-research
Project: /path/to/your/notes

## What to do
After card 008-sourced-research is done, read its `card.md`, `result.md` and `review.md`; find the location of the source notes from the result. Based on `research.md` and `source-check.md`, write `decision-memo.md`. Present it to the person who will choose the task-tracking approach for the five-person team in at most 150 words including headings and options. State the need in one sentence, give one gain and one cost for each of the three options, then one reasoned recommendation and one condition that would change the decision. In the last sentence say which option you are asking the decision owner to choose. The recommendation is not the user's decision; do not write it as if it were chosen. Do no new research; keep the verified source link from 008 for every factual claim. Put the mapping between the memo and its support into the `result.md` next to the card.

## Do not touch
Only `decision-memo.md` and this card's `result.md` may be written. The research, the source check, other cards and the user's decision records cannot be changed. Do not read or change `.env` and key files. Purchasing, opening accounts or applying the decision are out of scope.

## If you get stuck
Stop and tell Sheepdog if 008 is not done, its review result is not PASSED, the source notes are missing, or 30 minutes pass. If the research is insufficient for a choice, present the options "reopen the research for the missing criterion / accept the uncertainty and ask for a decision" to be relayed to the user. Do not choose on the user's behalf.

## Definition of done
- [ ] The output of `wc -w decision-memo.md` is at most 150; headings and options are included in the count. The command and output are in `result.md` → `Length`.
- [ ] The memo has one gain and one cost for each of the three options, a single recommendation, the reasoning, the condition that changes it and an explicit decision question. The matching sentences are mapped in `result.md` → `Content audit`.
- [ ] `result.md` → `Basis`: the file paths read from 008 and its review result, and a mapping memo claim → research section → verified source link; no new factual claim from outside the research was added.
- [ ] In `result.md` → `Delivery` next to the card: paths of the produced files, the verification commands that were run, their outputs and exit codes; the worker did not change the card state.
