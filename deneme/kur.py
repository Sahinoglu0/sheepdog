"""Sets up the trial repo and ready cards (en|tr); never deletes files. / Deneme deposunu ve kartları kurar."""

from pathlib import Path
import os
import shlex
import shutil
import subprocess
import sys


def _dil(argv):
    if "--lang" in argv:
        i = argv.index("--lang")
        deger = argv[i + 1] if i + 1 < len(argv) else ""
        del argv[i:i + 2]
        return deger if deger in ("en", "tr") else None
    deger = os.environ.get("SHEEPDOG_LANG", "").strip()
    if not deger:
        try:
            deger = (Path(__file__).resolve().parent.parent / ".dil").read_text().split()[0]
        except (OSError, IndexError):
            deger = ""
    return deger if deger == "tr" else "en"


DIL = "en"


def M(tr, en):
    return tr if DIL == "tr" else en


def kartlar_adlari():
    if DIL == "tr":
        return ("901-iade-hatasi", "902-gecikme-listesi", "903-kullanim-notu")
    return ("901-early-return-bug", "902-overdue-list", "903-usage-note")


def kaynak_kok(deneme):
    return deneme if DIL == "tr" else deneme / "en"


def paket_adi():
    return "kitaplik" if DIL == "tr" else "library"


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
        raise ValueError(M("Hedef sembolik bağlantı olamaz","The target must not be a symlink"))
    hedef = ham_hedef.resolve()
    hedef_yolu = hedef.as_posix()
    if any(c in hedef_yolu for c in "\n\r"):
        raise ValueError(M("Hedef yolunda satır sonu olamaz","The target path must not contain a newline"))
    if hedef.exists() and (not hedef.is_dir() or any(hedef.iterdir())):
        raise ValueError(M("Hedef boş bir klasör olmalı; hiçbir şey değiştirilmedi","The target must be an empty folder; nothing was changed"))
    if not shutil.which("git"):
        raise ValueError(M("git bulunamadı; hiçbir şey değiştirilmedi","git not found; nothing was changed"))
    if any(os.environ.get(ad) for ad in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_COMMON_DIR")):
        raise ValueError(M("GIT_DIR/WORK_TREE/INDEX_FILE/COMMON_DIR ayarlarını kaldırıp yeniden deneyin","Unset GIT_DIR/WORK_TREE/INDEX_FILE/COMMON_DIR and try again"))
    if isler.is_symlink() or (isler.exists() and not isler.is_dir()):
        raise ValueError(M("Merkezin isler yolu normal bir klasör olmalı","The hub's isler path must be a normal folder"))
    for korunan in (deneme, isler):
        if hedef == korunan or korunan in hedef.parents or hedef in korunan.parents:
            raise ValueError(M("Hedef, deneme veya isler klasörüyle iç içe olamaz","The target must not be nested with the deneme or isler folders"))

    # Bütün çakışmaları ve şablonları yazmaya başlamadan kontrol et.
    kartlar = {}
    kok = kaynak_kok(deneme)
    for ad in kartlar_adlari():
        if os.path.lexists(str(isler / ad)):
            raise ValueError(M("Kart zaten var: {} ; hiçbir şey değiştirilmedi","Card already exists: {} ; nothing was changed").format(ad))
        metin = (kok / "kartlar" / ad / "kart.md").read_text(encoding="utf-8")
        durum_taslak, durum_hazir = ("Durum: taslak", "Durum: hazir") if DIL == "tr" else ("Status: draft", "Status: ready")
        proje_alani = "Proje: {{PROJE}}" if DIL == "tr" else "Project: {{PROJE}}"
        if proje_alani not in metin or durum_taslak not in metin:
            raise ValueError(M("Kart şablonu geçersiz: ","Invalid card template: ") + ad)
        kartlar[ad] = metin.replace("{{PROJE}}", hedef_yolu).replace(durum_taslak, durum_hazir, 1)
    if not (kok / "proje" / paket_adi() / "__main__.py").is_file():
        raise ValueError(M("Deneme proje kaynağı bulunamadı","Trial project source not found"))

    hedef.mkdir(parents=True, exist_ok=True)
    # Son kontrolden sonra hedef dolmuşsa kopyalama başlamaz.
    if any(hedef.iterdir()):
        raise ValueError(M("Hedef artık boş değil; kopyalama yapılmadı","The target is no longer empty; nothing was copied"))
    for kaynak in (kok / "proje").iterdir():
        if kaynak.is_dir():
            shutil.copytree(kaynak, hedef / kaynak.name, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
        else:
            # 'xb' var olan bir dosyanın üzerine yazılmasını engeller.
            with kaynak.open("rb") as giris, (hedef / kaynak.name).open("xb") as cikis:
                shutil.copyfileobj(giris, cikis)
    git(hedef, "init", "-q", "-b", "main", "--template=")
    for alan, yedek in (("user.name", M("deneme","trial")), ("user.email", "deneme@example.invalid")):
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
        "commit", "-qm", M("Deneme kitaplık projesini başlat","Start the trial library project"))
    commit = git(hedef, "rev-parse", "--short", "HEAD")
    isler.mkdir(exist_ok=True)
    for ad, metin in kartlar.items():
        kart = isler / ad
        kart.mkdir()  # Eşzamanlı oluşmuş kartın da üzerine yazma.
        with (kart / "kart.md").open("x", encoding="utf-8", newline="\n") as dosya:
            dosya.write(metin)

    print(M("Deneme kuruldu: ", "Trial set up: ") + hedef_yolu)
    print(M("İlk commit: ", "First commit: ") + commit)
    print(M("Üç hazır kart: ", "Three ready cards: ") + ", ".join(kartlar_adlari()))
    print(M("\n1. Hedefte bir kez claude açıp güven onayını verin, sonra oturumdan çıkın:",
            "\n1. Open claude once in the target, accept the trust prompt, then exit the session:"))
    print("   cd " + shlex.quote(hedef_yolu))
    print("   claude")
    print(M("2. Merkeze dönüp Sheepdog'u başlatın:", "2. Go back to the hub and start Sheepdog:"))
    print("   cd " + shlex.quote(merkez.as_posix()))
    print("   claude --agent " + M("sheepdog-tr", "sheepdog") + " --name sheepdog --permission-mode auto")
    print(M('   Konuşmaya "hazır kartları başlat" yazın.', '   Tell it: "start the ready cards".'))
    print(M("3. Merkezde ayrı bir terminalde panoyu izleyin:", "3. Watch the board in a separate terminal in the hub:"))
    print("   " + M("./pano.sh --izle", "./sheepdog watch"))


def main():
    global DIL
    argv = sys.argv[1:]
    dil = _dil(argv)
    if dil is None:
        print("Usage / Kullanım: bash deneme/kur.sh <target-folder|hedef-klasör> [--lang en|tr]", file=sys.stderr)
        return 1
    DIL = dil
    if len(argv) != 1 or not argv[0].strip():
        print(M("Kullanım: bash deneme/kur.sh <hedef-klasör> [--lang en|tr]", "Usage: bash deneme/kur.sh <target-folder> [--lang en|tr]"), file=sys.stderr)
        return 1
    try:
        kur(argv[0])
    except (OSError, ValueError, subprocess.CalledProcessError) as hata:
        print(M("Kurulum hatası: {}", "Setup error: {}").format(hata), file=sys.stderr)
        if isinstance(hata, subprocess.CalledProcessError):
            print(hata.stderr, file=sys.stderr)
        print(M("Hiçbir dosya silinmedi. Kısmi kurulum varsa inceleyin; üzerine yazmak için yeniden çalıştırmayın.", "No file was deleted. If a partial setup exists, inspect it; do not rerun to overwrite."), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
