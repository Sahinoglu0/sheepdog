# Example cards and a card-writing guide

**English** · [Türkçe](README.tr.md)

These cards are drafts to adapt. File names, endpoints, test commands, versions and numeric targets are example project contracts; do not treat them as facts verified in your project. Don't run these jobs on the kit itself. Each card describes one deliverable and how it can be checked independently.

| Folder | Type | What it teaches |
|---|---|---|
| [001-bug-fix](en/001-bug-fix/card.md) | code | Reproduce a bug twice, prove the root cause, write a red/green regression test. |
| [002-csv-export](en/002-csv-export/card.md) | code | Set an output contract, an access boundary, and the threshold for a design decision. |
| [003-test-coverage](en/003-test-coverage/card.md) | code | Test edge cases without changing production behavior. |
| [004-dependency-upgrade](en/004-dependency-upgrade/card.md) | code | Bound a major-version move with official notes, compatibility tests and rollback criteria. |
| [005-safe-refactor](en/005-safe-refactor/card.md) | code | Pin current behavior with tests first, then split the function. |
| [006-setup-doc](en/006-setup-doc/card.md) | code | Actually run the document's commands in a clean environment. |
| [007-query-performance](en/007-query-performance/card.md) | code | Measure time and query count before/after with the same data and environment. |
| [008-sourced-research](en/008-sourced-research/card.md) | content | Map every claim to a source that was opened and checked. |
| [009-weekly-data-report](en/009-weekly-data-report/card.md) | content | Audit CSV rows and verify totals with an independent calculation. |
| [010-decision-memo](en/010-decision-memo/card.md) | content | Produce a decision note of at most 150 words with options from a dependent card. |

## Adapting a card to your project

1. Pick one outcome. From the hub root copy it: `mkdir -p jobs` and `cp -R examples/en/001-bug-fix jobs/001-bug-fix`. If the target exists, don't copy over it; choose an unused number. Name the folder `NNN-short-name` in lowercase ASCII and update the number in the title (or let `./sheepdog new` scaffold an empty card with the next number).
2. Replace the `Project:` value with the real absolute folder where the work happens. For a code card it must be a git repository. The hub's card folder and the target project's folder can differ.
3. Read the files and the existing contract. Change the example module names, test commands, the way the server is started, test data and expected responses to match the real project. State each command's prerequisites. For 004 fill in the real package name, exact old/new versions and the official migration links; for 008 the names and starting links of the two candidates; for 009 verify the date range, columns and currency. Evidence fields to be determined during the work, such as `<start-commit>`, are reported with the real value; don't run the placeholder command literally.
4. Write the allowed files and what is out of scope. Set the time limit, the reasons to stop, and the options that need a user decision. Resolve product decisions that are known at the start before the card is ready; if a new decision appears during the work, the worker asks Sheepdog with options.
5. If there is no dependency leave `Waits-for: none`. For a decision memo copy both 008 and 010, and make 010's `Waits-for:` equal 008's real folder name (comma-separated for several). If you rename a card, fix the card paths inside the text too. State where the source reports live in the project.
6. Add a command, an expected result and an evidence location to every acceptance item. For a code card ask for branch, commit and worktree path. For a content card ask for a source audit or a calculation check. If a document change will be tested on a git branch and merged, use `Type: code` as in 006.
7. Review the card as `Status: draft`. After the user approves, run `./sheepdog set 001-bug-fix ready`. See ready cards with dependencies finished using `./sheepdog ready`. The worker never changes card state.

## Format contract

Don't change the field names; don't add indentation, bullets or bold before them. The scripts read each field once and accept the English keys shown here or the Turkish ones (`Durum`, `Tür`, `Bekliyor`, `Proje`). `Type` is only `code` or `content` (`kod`/`icerik`). Sections in these examples are in this order:

```markdown
# 001: Short, concrete title

Status: draft
Type: code
Waits-for: none
Project: /path/to/your/project

## What to do
Target file, starting command, input and expected behavior.

## Do not touch
The allowed boundary, out-of-scope files and forbidden operations.

## If you get stuck
When to stop, the time limit, and the decision options to relay to Sheepdog.

## Definition of done
- [ ] A concrete output, the verification command and where the evidence is in result.md.
- [ ] A check that preserves existing behavior and its output in result.md.
- [ ] Delivered files; for code, branch, commit and worktree evidence.
```

The worker writes its result into `result.md` **next to the card**. Report or application files named in the card are placed relative to the `Project:` folder. The file paths in `result.md` must be enough for the reviewer to find them. For each command give the working directory, command, exit code and relevant output. Long outputs may go to an attachment linked relatively from the result. Output that contains secrets is not put into the report; state the masking needed. A check that could not be run is not a success; write it as blocked.

The worker commits code on its own worktree branch; it does not push, open a PR or merge into the main branch. When done or stuck it reports the result and file location to Sheepdog in one sentence. The reviewer evaluates the acceptance items and evidence. For a code card the verifier re-runs the commands; the merger merges if the project rules and checks pass. A content card ends after review; it does not enter code verification and merging. State is managed by Sheepdog with `state.sh`, not by the worker.

## Good card checklist

- [ ] Does the card produce one outcome that another person can check?
- [ ] Are the file/module, starting command, input and expected behavior concrete?
- [ ] Does every "Definition of done" item have a measurable threshold or an exact expected output?
- [ ] Are the writable files, out-of-scope work and the `.env`/key ban explicit?
- [ ] Are the points that need a user decision, and their options, written down?
- [ ] Is there a time limit and a condition to stop and tell Sheepdog?
- [ ] Is it clear where the evidence will be in `result.md` and how to repeat the check?
- [ ] Are the type, dependency, project path and the branch/commit delivery of a code card correct?

## Bad and good acceptance items

| Bad "Definition of done" | Good "Definition of done" |
|---|---|
| The API works well. | `python -m pytest tests/test_orders.py -q` exits 0; 200 for an empty page and 400 for invalid text are tested; command/output are in `result.md` → `Checks`. |
| The query got faster. | With the same 1000 orders the median of ten measurements dropped at least 30%; raw times and the calculation are in `result.md` → `Comparison`. |
| The research is reliable. | Every factual claim has an opened source link next to it; access date and supporting section are in `source-check.md`, the mapping in `result.md` → `Claim audit`. |
| The report is complete. | The daily cent total equals the direct weekly total and an independent second calculation; the three results are in `result.md` → `Cross-check`. |
