"""Yerel JSON dosyasında saklama; ek bağımlılık veya sunucu gerekmez."""

import json
import os
from pathlib import Path
import tempfile


def oku(yol):
    dosya = Path(yol)
    if not dosya.exists():
        return {"kitaplar": {}, "oduncler": []}
    return json.loads(dosya.read_text(encoding="utf-8"))


def yaz(yol, veri):
    dosya = Path(yol)
    # Aynı dizindeki geçici dosya, yarım yazılmış JSON bırakmayı önler.
    with tempfile.NamedTemporaryFile(
        mode="w", encoding="utf-8", dir=dosya.parent, delete=False
    ) as gecici:
        ad = gecici.name
        try:
            json.dump(veri, gecici, ensure_ascii=False, indent=2)
        except BaseException:
            gecici.close()
            os.unlink(ad)
            raise
    try:
        os.replace(ad, dosya)
    finally:
        if os.path.exists(ad):
            os.unlink(ad)
