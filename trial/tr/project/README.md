# Kitaplık

Python 3.8+ standart kütüphanesiyle çalışan küçük ödünç takip uygulaması.
Her kitap kodu tek fiziksel nüshadır; ödünç süresi 14 gündür. Sunucu veya paket kurulumu gerekmez.
Komutları bu klasörde çalıştırın (`python3` yoksa Python 3 olan `python` kullanın):

```bash
python3 -m unittest
python3 -m kitaplik --help
python3 -m kitaplik ekle K1 "Küçük Prens"
python3 -m kitaplik odunc K1 Ada --tarih 2026-01-01
python3 -m kitaplik iade 1 --tarih 2026-01-18
```

Son komut `İade alındı. Gecikme: 3 gün` yazar. Kayıtlar varsayılan olarak
`kitaplik.json` içindedir; başka dosya için komuttan önce `--veri kayit.json` verin.
Tarihler `YYYY-AA-GG` biçimindedir; son teslim günü gecikmiş sayılmaz.

## Deneme için bırakılan işler

Başlangıçtaki 8 test geçer. Erken iadeyi kapsamadıkları için aşağıdaki gerçek
hesaplama hatasını yakalamazlar. İade işlemiyle aynı hesaplamayı kullanan,
dosya oluşturmayan tek komutla hatayı görün:

```bash
python3 -m kitaplik gecikme --son-tarih 2026-01-15 --iade-tarihi 2026-01-01
```

Başlangıç çıktısı `Gecikme: -14 gün`; doğru sonuç `Gecikme: 0 gün` olmalı.
901 kartı bunu regresyon testiyle düzeltecek. Geciken açık ödünçleri listeleyen
bir komut henüz yok; 902 kartı ekleyecek. Bu iki iş ayrı modüllerde yürütülebilir:
hesap düzeltmesi `islemler.py`, yeni liste özelliği `__main__.py` ve yeni bir modül.
