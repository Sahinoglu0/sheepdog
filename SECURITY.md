# Security policy

**English** · [Türkçe](SECURITY.tr.md)

Sheepdog launches autonomous coding sessions in auto permission mode. Read the **Safety and limits** section of the [README](README.md) before using it on anything important.

## Known limits (by design)

- Role restrictions (no pushing, no editing state, no reading `.env`) are prompt rules, not locks.
- The manager has Bash. "No file-writing tool" is a behavior rule, not a sandbox.
- `--add-dir` adds access to a session; it does not restrict it. A worker may be able to write outside its card folder, including the hub.
- Review independence is a prompt rule: the card folder is writable by every role.
- Sessions can be influenced by text they read from the web or from repositories.

Run important work in a separate OS account or container.

## Reporting a vulnerability

Please use GitHub's private vulnerability reporting (**Security → Report a vulnerability**) on this repository. Do not open a public issue for exploitable problems. Include the version (see `CHANGELOG.md`), your OS, and a minimal reproduction. We aim to acknowledge reports within a week.
