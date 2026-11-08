# 006: Fix the setup doc by running it in a clean environment

Status: draft
Type: code
Waits-for: none
Project: /path/to/your/project

## What to do
Verify the install and first-run steps in the root `README.md` of the Python-based example project. Record the starting commit; export the tracked files into a fresh temporary folder with `git archive HEAD`. There create an empty environment with `python3 -m venv .venv`; do not use user site packages or the existing project environment. Run the install commands written in the doc, in order, exactly as written. Find the cause of any failing step and fix only the command or the missing prerequisite in the README. In this example the successful flow is `.venv/bin/python -m pip install -r requirements.txt`, `.venv/bin/python -m pytest -q`, and `curl -i http://127.0.0.1:8000/health` against the local server started with `.venv/bin/python -m api`; the last request must return 200 and `{"status":"ok"}`. After the fixes, verify the whole flow again from scratch with the corrected README in a second, empty temporary environment; stop the server you started.

## Do not touch
In the target project only the root `README.md` may change. The application, dependency files, CI and the user's existing environments are out of scope. Do not read or change `.env` and key files. Use no real service or production data. No push, no PR and no merging into the main branch.

## If you get stuck
Stop if the setup asks for a secret or a paid service, an application error appears, there is no network access, or 45 minutes pass. Send Sheepdog the options "secret-free local trial path / separate configuration card" and wait for the user's decision. Do not mark a step you did not run as verified.

## Definition of done
- [ ] `sonuc.md` → `Clean environment`: the paths of both temporary folders, the starting commit, the operating system, the Python/pip versions and the outputs of the environment-creation commands.
- [ ] `sonuc.md` → `Step log`: all commands in README step order, exit codes, the first errors and the reasons for the fixes; in the second environment the install and test commands exit 0.
- [ ] `sonuc.md` → `First run`: the server start/stop commands and the output showing the health request returned 200 with the expected body; it is shown that every README step was run in the second environment.
- [ ] `sonuc.md` → `Delivery`: the real starting commit, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` and `git diff <start-commit> HEAD --stat` with their outputs; the branch name, commit hash and worktree path are stated. Changes are in the allowed files only and committed on its own branch.
