# 009: Sipariş CSV dosyasından doğrulanabilir haftalık özet çıkar

Durum: taslak
Tür: icerik
Bekliyor: yok
Proje: /notlarinizin/klasörü

## Ne yapılacak
`veri/siparisler.csv` dosyasından `raporlar/haftalik-ozet.md` üret. Girdi UTF-8, virgülle ayrılmış ve `siparis_id,tarih,durum,tutar_kurus` sütunlarına sahip olsun; her satır bir siparişi, tarih saat dilimsiz `YYYY-MM-DD` yerel takvim gününü temsil etsin. Rapor haftası 2026-10-26 dahil, 2026-11-02 hariç aralığıdır. `tamamlandi` siparişlerin adet ve toplam kuruş tutarını, gün bazında dağılımını ve en yakın kuruşa yarım yukarı yuvarlanan ortalamasını hesapla. `iptal` kayıtları gelirden çıkar, sayısını ayrıca göster. Dosyanın bütününde yinelenen sipariş kimliğini, eksik alanı, geçersiz tarihi/durumu ve negatif ya da tam sayı olmayan kuruş değerini denetle; sessizce satır atlama. Hesap için standart kütüphaneli `raporlar/haftalik_hesap.py` yaz. Günlük toplamların haftalık toplamla eşleşmesini kontrol et; ayrıca haftalık toplamı günlük gruplamayı kullanmadan bağımsız bir ikinci geçişle doğrula. Girdi hash’ini kaydet; rapora kişisel veri veya ham satır ekleme.

## Neye dokunma
Yalnız `raporlar/haftalik-ozet.md`, `raporlar/haftalik_hesap.py` ve kartın yanındaki `sonuc.md` yazılabilir. Kaynak CSV salt okunur; diğer haftalar ve muhasebe kayıtları kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Veriyi dış servise yükleme.

## Takılırsan
Şema farklıysa, bozuk veya yinelenen satır varsa ya da 45 dakika dolarsa dur. Kimlikleri ifşa etmeden satır numaraları ve sorun sayısını süper ajana bildir. “Düzeltilmiş girdi bekle / sorunlu satırları ayrı sayıp kapsamı daralt” seçeneklerini kullanıcıya sorulmak üzere ilet; karar gelmeden raporu tamamlanmış gösterme.

## Bitti demek
- [ ] `python3 raporlar/haftalik_hesap.py veri/siparisler.csv --baslangic 2026-10-26 --bitis 2026-11-02` çıkış kodu 0; komut ve çıktı `sonuc.md` → `Hesap` içinde. Betik sözleşmesi bu argümanları kabul ediyor; girdi SHA-256 değeri aynı başlıkta.
- [ ] `sonuc.md` → `Satır denetimi`: toplam satır, hafta içi/dışı satır, tamamlanan ve iptal adetleri var; geçersiz ve yinelenen kayıt sayısı 0. Toplam satır = hafta içi + hafta dışı; hafta içi = tamamlanan + iptal eşitlikleri sayılarla gösterilmiş.
- [ ] `sonuc.md` → `Çapraz kontrol`: günlük tutarların toplamı, doğrudan haftalık toplam ve ikinci geçiş sonucu kuruş cinsinden eşit. Ortalama için toplam/adet hesabı ve yuvarlama yazılı; adet 0 ise ortalama “hesaplanamadı” olarak gösterilmiş.
- [ ] `raporlar/haftalik-ozet.md` tarih aralığını, para biriminin kuruş olduğunu, yedi günlük tabloyu ve iptal sayısını içeriyor; bütün sayılar betik çıktısıyla eşleştirilmiş. Eşleştirme `sonuc.md` → `Rapor denetimi` içinde.
- [ ] Kartın yanındaki `sonuc.md` → `Teslim` bölümünde üretilen dosyaların yolları, çalıştırılan denetim komutları, çıktıları ve çıkış kodları var; işçi kart durumunu değiştirmemiş.
