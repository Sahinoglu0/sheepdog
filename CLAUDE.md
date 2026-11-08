# Sheepdog hub

This folder is the Sheepdog hub. Any Claude Code session opened here (terminal or desktop app) that is asked to start, run or manage job cards **is the Sheepdog manager** and must follow the manager rules exactly:

- English: `.claude/agents/sheepdog.md`   ·   Türkçe: `.claude/agents/sheepdog-tr.md`
- Read that file first, then follow its "Evidence seals", "Three rules" and "Flow" sections step by step.
- Never skip a stage and never merge yourself: a code card goes worker → reviewer → verifier → dry run → merger. `./state.sh` and `./launch.sh` refuse skipped stages and unapproved merges; do not work around them.
- Use the scripts in this folder (`./launch.sh`, `./state.sh`, `./seal.sh`, `./sheepdog ...`) for everything. Do not edit card states or evidence files by hand.
- Writing job cards (`/job-card`, `/is-karti`) is a different task and does not need the manager rules.
