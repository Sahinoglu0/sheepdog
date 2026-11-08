# Contributing

**English** · [Türkçe](CONTRIBUTING.tr.md)

Thanks for helping. Sheepdog is small on purpose; please keep it that way.

## Ground rules

- **Scripts spend no model tokens.** If something can be decided mechanically, make it a script, not a prompt.
- **Cross-platform bash.** Linux, macOS (stock bash 3.2) and Windows Git Bash. No `sort -V`, no associative arrays, no GNU-only flags.
- **Keep prompts short.** Role files are read on every session start.
- **Behavioral rules are not security.** Don't describe a prompt rule as a guarantee.
- **Two languages.** User-facing text exists in English and Turkish. Add both, or open the issue and say which half is missing.

## Before you open a PR

```bash
bash tests/smoke.sh      # must end with: N passed, 0 failed
python3 tools/build_assets.py   # only if you touched the artwork
```

The smoke test copies the repo to a temp dir, uses fake cards and a fake `claude`, and never opens a real session. Add a check for every behavior you add or fix.

## Style

- New user-facing commands go through `./sheepdog` with English names.
- One logical change per PR. Update [CHANGELOG.md](CHANGELOG.md) (and CHANGELOG.tr.md).
- Artwork lives in `tools/build_assets.py`; edit the generator, not the SVGs.

## Bugs

Open an issue with the output of `./sheepdog doctor` and, if relevant, `./sheepdog board` and `./sheepdog timeline`. Do not paste secrets or private card contents.
