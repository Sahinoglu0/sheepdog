"""Deneme deposunu ve hazır kartları kurar; mevcut dosyaları silmez."""

from pathlib import Path
import os
import shlex
import shutil
import subprocess
import sys


KARTLAR = ("901-iade-hatasi", "902-gecikme-listesi", "903-kullanim-notu")


def git(hedef, *args):
    return subprocess.run(
        ["git", "-C", str(hedef)] + list(args), check=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        encoding="utf-8", errors="replace",
    ).stdout.strip()


def kur(hedef_arg):
    deneme = Path(__file__).resolve().parent
    merkez = deneme.parent
    isler = merkez / "isler"
    ham_hedef = Path(hedef_arg).expanduser()
    if ham_hedef.is_symlink():
        raise ValueError("Hedef sembolik bağlantı olamaz")
    hedef = ham_hedef.resolve()
    hedef_yolu = hedef.as_posix()
    if any(c in hedef_yolu for c in "\n\r"):
        raise ValueError("Hedef yolunda satır sonu olamaz")
    if hedef.exists() and (not hedef.is_dir() or any(hedef.iterdir())):
        raise ValueError("Hedef boş bir klasör olmalı; hiçbir şey değiştirilmedi")
    if not shutil.which("git"):
        raise ValueError("git bulunamadı; hiçbir şey değiştirilmedi")
    if any(os.environ.get(ad) for ad in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_COMMON_DIR")):
        raise ValueError("GIT_DIR/WORK_TREE/INDEX_FILE/COMMON_DIR ayarlarını kaldırıp yeniden deneyin")
    if isler.is_symlink() or (isler.exists() and not isler.is_dir()):
        raise ValueError("Merkezin isler yolu normal bir klasör olmalı")
    for korunan in (deneme, isler):
        if hedef == korunan or korunan in hedef.parents or hedef in korunan.parents:
            raise ValueError("Hedef, deneme veya isler klasörüyle iç içe olamaz")

    # Bütün çakışmaları ve şablonları yazmaya başlamadan kontrol et.
    kartlar = {}
    for ad in KARTLAR:
        if os.path.lexists(str(isler / ad)):
            raise ValueError("Kart zaten var: {} ; hiçbir şey değiştirilmedi".format(ad))
        metin = (deneme / "kartlar" / ad / "kart.md").read_text(encoding="utf-8")
        if "Proje: {{PROJE}}" not in metin or "Durum: taslak" not in metin:
            raise ValueError("Kart şablonu geçersiz: " + ad)
        kartlar[ad] = metin.replace("{{PROJE}}", hedef_yolu).replace("Durum: taslak", "Durum: hazir", 1)
    if not (deneme / "proje" / "kitaplik" / "__main__.py").is_file():
        raise ValueError("Deneme proje kaynağı bulunamadı")

    hedef.mkdir(parents=True, exist_ok=True)
    # Son kontrolden sonra hedef dolmuşsa kopyalama başlamaz.
    if any(hedef.iterdir()):
        raise ValueError("Hedef artık boş değil; kopyalama yapılmadı")
    for kaynak in (deneme / "proje").iterdir():
        if kaynak.is_dir():
            shutil.copytree(kaynak, hedef / kaynak.name, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
        else:
            # 'xb' var olan bir dosyanın üzerine yazılmasını engeller.
            with kaynak.open("rb") as giris, (hedef / kaynak.name).open("xb") as cikis:
                shutil.copyfileobj(giris, cikis)
    git(hedef, "init", "-q", "-b", "main", "--template=")
    for alan, yedek in (("user.name", "deneme"), ("user.email", "deneme@example.invalid")):
        try:
            deger = git(hedef, "config", "--global", "--get", alan)
        except subprocess.CalledProcessError as hata:
            if hata.returncode != 1:
                raise
            deger = ""
        if not deger:
            git(hedef, "config", "--local", alan, yedek)
    git(hedef, "add", "--all")
    git(hedef, "-c", "commit.gpgsign=false", "-c", "core.hooksPath=" + str(hedef / ".git" / "bos-kancalar"),
        "commit", "-qm", "Deneme kitaplık projesini başlat")
    commit = git(hedef, "rev-parse", "--short", "HEAD")
    isler.mkdir(exist_ok=True)
    for ad, metin in kartlar.items():
        kart = isler / ad
        kart.mkdir()  # Eşzamanlı oluşmuş kartın da üzerine yazma.
        with (kart / "kart.md").open("x", encoding="utf-8", newline="\n") as dosya:
            dosya.write(metin)

    print("Deneme kuruldu: " + hedef_yolu)
    print("İlk commit: " + commit)
    print("Üç hazır kart: " + ", ".join(KARTLAR))
    print("\n1. Hedefte bir kez claude açıp güven onayını verin, sonra oturumdan çıkın:")
    print("   cd " + shlex.quote(hedef_yolu))
    print("   claude")
    print("2. Merkeze dönüp süper ajanı başlatın:")
    print("   cd " + shlex.quote(merkez.as_posix()))
    print("   claude --agent super-ajan --name super-ajan --permission-mode auto")
    print('   Konuşmaya "hazır kartları başlat" yazın.')
    print("3. Merkezde ayrı bir terminalde panoyu izleyin:")
    print("   ./pano.sh --izle")


def main():
    if len(sys.argv) != 2 or not sys.argv[1].strip():
        print("Kullanım: bash deneme/kur.sh <hedef-klasör>", file=sys.stderr)
        return 1
    try:
        kur(sys.argv[1])
    except (OSError, ValueError, subprocess.CalledProcessError) as hata:
        print("Kurulum hatası: {}".format(hata), file=sys.stderr)
        if isinstance(hata, subprocess.CalledProcessError):
            print(hata.stderr, file=sys.stderr)
        print("Hiçbir dosya silinmedi. Kısmi kurulum varsa inceleyin; üzerine yazmak için yeniden çalıştırmayın.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
