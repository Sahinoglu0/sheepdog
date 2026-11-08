# 004: Move the HTTP client to the next major version

Status: draft
Type: code
Waits-for: none
Project: /path/to/your/project

## What to do
In this example `http-client` in `package.json` is a placeholder for the project's real HTTP client package; fill in its name and the exact source/target versions before the card is made ready. Limit the move from the current 1.x to the approved 2.x to `package.json`, `package-lock.json`, `src/client.ts` and `tests/client.test.ts`. First record the baseline with `npm ci` and `npm test -- --run`. Open the official release notes and migration guide; match every breaking change in request building, timeouts, the error object and retry behavior with its usage sites. Update only the target package and its required transitive dependencies. After adapting, run a clean install, the tests and the build. Rollback criteria: a test that passed at baseline in the same environment fails, the timeout/retry contract cannot be preserved, or the supported runtime is incompatible. In that case stop the delivery and write a plan that reverts the previous manifest, lockfile and client changes together.

## Do not touch
Anything outside the four listed files, bulk updates of other packages, the runtime major version and CI configuration are out of scope. Do not read or change `.env` and key files. No push, no PR and no merging into the main branch. Do not reset or rewrite history to roll back.

## If you get stuck
Stop if the placeholder/version choice is unresolved, the official notes cannot be reached, or 60 minutes pass. If a runtime upgrade or behavior change is needed, send Sheepdog the options "postpone the upgrade / open a separate compatibility card" and wait for the user's decision. If a rollback criterion occurred, also report the failing command; do not loosen the tests.

## Definition of done
- [ ] `result.md` → `Versions and sources`: exact old/new versions, the official links that were opened, the access date, and for every breaking change its file or the reason it did not apply.
- [ ] `npm ci`, `npm test -- --run` and `npm run build` exit 0; baseline and post-upgrade commands/outputs are in `result.md` → `Checks`. The names of the timeout, error and retry tests are stated.
- [ ] The output of `git diff <start-commit> HEAD -- package.json package-lock.json` and the reasons for any transitive changes are in `result.md` → `Dependency diff`; there is no unrelated package update.
- [ ] `result.md` → `Rollback`: evidence that each criterion occurred or did not, the exact previous version, and the steps to restore version and files together. If a criterion occurred, the job does not count as done.
- [ ] `result.md` → `Delivery`: the real starting commit, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` and `git diff <start-commit> HEAD --stat` with their outputs; the branch name, commit hash and worktree path are stated. Changes are in the allowed files only and committed on its own branch.
