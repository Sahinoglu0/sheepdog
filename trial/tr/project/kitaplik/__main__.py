"""Komut satırı girişi: python3 -m kitaplik --help."""

import argparse
import sys

from . import depo, islemler


def main(argv=None):
    parser = argparse.ArgumentParser(description="Kütüphane ödünç takibi")
    parser.add_argument("--veri", default="kitaplik.json", help="Yerel JSON dosyası")
    komutlar = parser.add_subparsers(dest="komut", required=True)
    ekle = komutlar.add_parser("ekle", help="Bir kitap ekle")
    ekle.add_argument("kod")
    ekle.add_argument("ad")
    odunc = komutlar.add_parser("odunc", help="14 günlüğüne ödünç ver")
    odunc.add_argument("kod")
    odunc.add_argument("uye")
    odunc.add_argument("--tarih", required=True)
    iade = komutlar.add_parser("iade", help="Ödüncü numarasıyla iade al")
    iade.add_argument("no", type=int)
    iade.add_argument("--tarih", required=True)
    gecikme = komutlar.add_parser("gecikme", help="Dosyaya yazmadan gecikme hesapla")
    gecikme.add_argument("--son-tarih", required=True)
    gecikme.add_argument("--iade-tarihi", required=True)
    args = parser.parse_args(argv)
    try:
        if args.komut == "gecikme":
            gun = islemler.gecikme_gunu(args.son_tarih, args.iade_tarihi)
            print("Gecikme: {} gün".format(gun))
            return 0
        veri = depo.oku(args.veri)
        if args.komut == "ekle":
            islemler.kitap_ekle(veri, args.kod, args.ad)
            mesaj = "Kitap eklendi: " + args.kod
        elif args.komut == "odunc":
            no = islemler.odunc_ver(veri, args.kod, args.uye, args.tarih)
            mesaj = "Ödünç no: {}".format(no)
        elif args.komut == "iade":
            gun = islemler.iade_al(veri, args.no, args.tarih)
            mesaj = "İade alındı. Gecikme: {} gün".format(gun)
        depo.yaz(args.veri, veri)
        print(mesaj)
        return 0
    except (ValueError, OSError) as hata:
        print("Hata: {}".format(hata), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
