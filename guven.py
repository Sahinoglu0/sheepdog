"""Güven onayı kontrolü. kullanım: python3 guven.py <proje-klasörü>  (çıkış 0: onaylı, 1: onaysız)

Claude Code arka plan oturumu git deposunda üst klasörün onayını saymaz: klasörün kendisi
veya git kökü onaylı olmalı. Git deposu değilse üst klasörlerden biri yeter.
Linux, macOS ve Windows'ta çalışır; yollar karşılaştırılmadan önce normalleştirilir.
"""
import json
import os
import shutil
import subprocess
import sys


def norm(yol):
    return os.path.normcase(os.path.realpath(yol))


def ayarlar():
    yol = os.environ.get("SUPER_AJAN_CLAUDE_JSON") or os.path.join(os.path.expanduser("~"), ".claude.json")
    with open(yol, encoding="utf-8") as f:
        return {norm(k): v for k, v in json.load(f).get("projects", {}).items()}


def git_koku(yol):
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
        d = ayarlar()
    except (OSError, ValueError):
        return 1
    ok = lambda a: bool(d.get(norm(a), {}).get("hasTrustDialogAccepted"))
    p = norm(sys.argv[1])
    kok = git_koku(p)
    if kok:
        return 0 if ok(p) or ok(kok) else 1
    while True:
        if ok(p):
            return 0
        ust = os.path.dirname(p)
        if ust == p:
            return 1
        p = ust


if __name__ == "__main__":
    sys.exit(main())
