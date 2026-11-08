---
name: job-card
description: Turns a request into job cards a worker agent can complete without asking questions. Use for "write a job card", "split this job", "prepare this job".
---

# Writing job cards

Turn the request into job cards. The worker cannot ask questions later, so close every ambiguity now.

## Steps

1. Split the request into parts. A card is the smallest job that can be finished and checked on its own.
2. Briefly look at the files and existing work involved.
3. Ask the user one question at a time. If there are options, put your recommendation first. Stop when nothing is left that the worker would have to decide on its own. If the user does not answer, do not assume: write the question into the card as pending.
4. Save each card as `isler/001-short-name/kart.md` (the folder is `isler`, the file `kart.md`). Number them in order.
5. Leave all of them `Status: draft`. When the user approves, set `Status: ready` (`./durum.sh isler/<card> ready`). `Type` is `code` or `content`. If a card waits on others, write their folder names in `Waits-for:` (comma-separated).

The scripts accept both the English field names below and the Turkish ones (`Durum`, `Tür`, `Bekliyor`, `Proje`).

## Card template

```markdown
# 001: Short title

Status: draft
Type: code
Waits-for: none
Project: /absolute/path/where/the/work/happens

## What to do
One paragraph. Someone should be able to do it without asking questions.

## Do not touch
What is out of scope.

## Definition of done
- [ ] What will be true, and what proves it.
- [ ] What will be true, and what proves it.

## If you get stuck
Where to stop and report.
```

"Definition of done" items must be clear enough that someone who did not do the job can say yes or no. "The report should be good" is not enough. "Every claim has a source link next to it" is.
