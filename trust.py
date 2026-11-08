"""Trust prompt check. usage: python3 trust.py <project-folder>  (exit 0: approved, 1: not approved)

A Claude Code background session in a git repository does not count a parent folder's approval: the folder
itself or the git root must be approved. Outside a git repo, any parent folder is enough.
Works on Linux, macOS and Windows; paths are normalized before they are compared.
"""
import json
import os
import shutil
import subprocess
import sys


def norm(yol):
    return os.path.normcase(os.path.realpath(yol))


def settings():
    yol = os.environ.get("SHEEPDOG_CLAUDE_JSON") or os.path.join(os.path.expanduser("~"), ".claude.json")
    with open(yol, encoding="utf-8") as f:
        return {norm(k): v for k, v in json.load(f).get("projects", {}).items()}


def git_root(yol):
    git = shutil.which("git")
    if not git:
        return ""
    r = subprocess.run([git, "-C", yol, "rev-parse", "--show-toplevel"], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else ""


def main():
    if len(sys.argv) != 2:
        print(__doc__.strip().splitlines()[0])
        return 2
    try:
        d = settings()
    except (OSError, ValueError):
        return 1
    ok = lambda a: bool(d.get(norm(a), {}).get("hasTrustDialogAccepted"))
    p = norm(sys.argv[1])
    kok = git_root(p)
    if kok:
        return 0 if ok(p) or ok(kok) else 1
    while True:
        if ok(p):
            return 0
        parent = os.path.dirname(p)
        if parent == p:
            return 1
        p = parent


if __name__ == "__main__":
    sys.exit(main())
