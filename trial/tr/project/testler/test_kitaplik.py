import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from kitaplik import islemler


class IslemTestleri(unittest.TestCase):
    def setUp(self):
        self.veri = {"kitaplar": {}, "oduncler": []}
        islemler.kitap_ekle(self.veri, "K1", "Küçük Prens")

    def test_kitap_ekleme_ve_tekrar_kodu_reddetme(self):
        self.assertEqual(self.veri["kitaplar"]["K1"], "Küçük Prens")
        with self.assertRaises(ValueError):
            islemler.kitap_ekle(self.veri, "K1", "Başka kitap")

    def test_odunc_suresi_ve_ayni_kitabi_tekrar_vermeme(self):
        self.assertEqual(islemler.odunc_ver(self.veri, "K1", "Ada", "2026-01-01"), 1)
        self.assertEqual(self.veri["oduncler"][0]["son_tarih"], "2026-01-15")
        with self.assertRaises(ValueError):
            islemler.odunc_ver(self.veri, "K1", "Ece", "2026-01-02")

    def test_olmayan_kitap(self):
        with self.assertRaises(ValueError):
            islemler.odunc_ver(self.veri, "K2", "Ada", "2026-01-01")

    def test_son_gun_iade_ve_yeniden_odunc(self):
        no = islemler.odunc_ver(self.veri, "K1", "Ada", "2026-01-01")
        self.assertEqual(islemler.iade_al(self.veri, no, "2026-01-15"), 0)
        self.assertEqual(islemler.odunc_ver(self.veri, "K1", "Ece", "2026-01-16"), 2)

    def test_gec_iade(self):
        no = islemler.odunc_ver(self.veri, "K1", "Ada", "2026-01-01")
        self.assertEqual(islemler.iade_al(self.veri, no, "2026-01-18"), 3)

    def test_oduncten_once_iade_reddedilir(self):
        no = islemler.odunc_ver(self.veri, "K1", "Ada", "2026-01-01")
        with self.assertRaises(ValueError):
            islemler.iade_al(self.veri, no, "2025-12-31")
        self.assertIsNone(self.veri["oduncler"][0]["iade"])

    def test_ikinci_iade_reddedilir(self):
        no = islemler.odunc_ver(self.veri, "K1", "Ada", "2026-01-01")
        islemler.iade_al(self.veri, no, "2026-01-15")
        with self.assertRaises(ValueError):
            islemler.iade_al(self.veri, no, "2026-01-16")


class KomutTestleri(unittest.TestCase):
    def test_ayri_sureclerde_kayit_ve_iade(self):
        with tempfile.TemporaryDirectory() as klasor:
            yol = Path(klasor) / "kayit.json"
            def calistir(*args):
                return subprocess.run(
                    [sys.executable, "-m", "kitaplik", "--veri", str(yol)] + list(args),
                    capture_output=True, text=True, encoding="utf-8",
                    env=dict(os.environ, PYTHONIOENCODING="utf-8"),
                )
            self.assertEqual(calistir("ekle", "K1", "Küçük Prens").returncode, 0)
            self.assertEqual(calistir("odunc", "K1", "Ada", "--tarih", "2026-01-01").returncode, 0)
            sonuc = calistir("iade", "1", "--tarih", "2026-01-18")
            self.assertEqual(sonuc.returncode, 0, sonuc.stderr)
            self.assertIn("Gecikme: 3 gün", sonuc.stdout)
            self.assertEqual(json.loads(yol.read_text(encoding="utf-8"))["oduncler"][0]["iade"], "2026-01-18")
            once = yol.read_bytes()
            self.assertEqual(calistir("iade", "1", "--tarih", "2026-01-19").returncode, 1)
            self.assertEqual(yol.read_bytes(), once)


if __name__ == "__main__":
    unittest.main()
