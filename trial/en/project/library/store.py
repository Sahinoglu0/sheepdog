"""Local JSON storage; no extra dependency or server needed."""

import json
import os
from pathlib import Path
import tempfile


def read(path):
    file = Path(path)
    if not file.exists():
        return {"books": {}, "loans": []}
    return json.loads(file.read_text(encoding="utf-8"))


def write(path, data):
    file = Path(path)
    # A temp file in the same directory avoids leaving half-written JSON behind.
    with tempfile.NamedTemporaryFile(
        mode="w", encoding="utf-8", dir=file.parent, delete=False
    ) as temp:
        name = temp.name
        try:
            json.dump(data, temp, ensure_ascii=False, indent=2)
        except BaseException:
            temp.close()
            os.unlink(name)
            raise
    try:
        os.replace(name, file)
    finally:
        if os.path.exists(name):
            os.unlink(name)
