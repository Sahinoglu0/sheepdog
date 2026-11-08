# Contributing

Thanks for helping. Sheepdog is small on purpose; please keep it that way.

## Ground rules

- **Scripts spend no model tokens.** If something can be decided mechanically, make it a script, not a prompt.
- **Cross-platform bash.** Linux, macOS (stock bash 3.2) and Windows Git Bash. No `sort -V`, no associative arrays, no GNU-only flags.
- **Keep prompts short.** Role files are read on every session start.
- **Behavioral rules are not security.** Don't describe a prompt rule as a guarantee.

## Before you open a PR

```bash
bash testler/duman.sh      # must end with: N passed, 0 failed
```

The smoke test copies the repo to a temp dir, uses fake cards and a fake `claude`, and never opens a real session. Add a check for every behavior you add or fix.

## Style

- Turkish identifiers are legacy (see [docs/GLOSSARY.md](docs/GLOSSARY.md)). New user-facing commands should be reachable through `./sheepdog` with English names.
- One logical change per PR. Update [CHANGELOG.md](CHANGELOG.md).

## Bugs

Open an issue with the output of `./sheepdog doctor` and, if relevant, `./sheepdog board` and `./sheepdog timeline`. Do not paste secrets or private card contents.
