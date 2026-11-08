# 008: Compare task-tracking options for a small team

Status: draft
Type: content
Waits-for: none
Project: /path/to/your/notes

## What to do
In `research.md` compare three approaches: Markdown cards in a git repository, a hosted kanban service, and a self-hosted task board. Scenario: a five-person team, 200 tasks a month, existing git use, a requirement to export tasks, and at most two hours of maintenance a month. These are research assumptions; do not present them as facts verified from an external source. Fill in the service names and starting links with the two candidates the user chooses before the card is made ready. Compare cost, data export, access permissions, offline work and maintenance load. Use at least five primary sources. Put a link right next to every factual claim; open every link and check the relevant text. Write the source title, URL, access date, document version if any, and the section that supports the claim into `source-check.md`. Mark inferences with their supporting links and assumptions with a separate label. The result is at most 800 words; do not decide, present the options and the uncertainties.

## Do not touch
Only `research.md`, `source-check.md` and the `sonuc.md` next to the card may be written. Other notes, account settings, purchases and publishing outside are out of scope. Do not read or change `.env` and key files. Do not write sources from memory, unopened links or unverified prices.

## If you get stuck
Stop and tell Sheepdog if the candidates or starting links are missing, the internet is unreachable, or 60 minutes pass. Record the uncertainty if sources conflict; if paid access is needed, ask the user through Sheepdog with the options "narrow the scope to accessible official sources / hold the research". Do not count an unreachable source as checked.

## Definition of done
- [ ] `research.md` compares the three approaches on five criteria; the result of `wc -w research.md` is at most 800. The command and output are in `sonuc.md` → `Scope`.
- [ ] At least five opened primary sources. `source-check.md` has the access date, the section and the supported claim for each link; `sonuc.md` → `Source audit` links to this file.
- [ ] Every factual claim has a supporting link next to it; inference and assumption labels are separate. `sonuc.md` → `Claim audit` maps each claim to its source-check record and lists unreachable or inferred claims.
- [ ] In `sonuc.md` → `Delivery` next to the card: paths of the produced files, the verification commands that were run, their outputs and exit codes; the worker did not change the card state.
