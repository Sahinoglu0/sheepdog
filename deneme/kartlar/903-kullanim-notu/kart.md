# 903: Gecikenler için kısa kullanım notu

Durum: taslak
Tür: icerik
Bekliyor: 902-gecikme-listesi
Proje: {{PROJE}}

## Ne yapılacak
902 bittikten sonra projenin ana dalındaki son README, `kitaplik/__main__.py` ve `kitaplik/listeleme.py` dosyalarını oku. Kullanıcıya yönelik 150–250 kelimelik Türkçe kullanım notunu bu kartın yanındaki `sonuc.md` dosyasına yaz. Kitap ekleme, ödünç verme ve gecikenleri listelemeyi, `--veri` ile ayrı veri dosyasını ve tarih biçimini anlat. 902'nin kullanıcı tarafından seçilmiş gerçek çıktı biçimini göster. Komutları geçici bir veri dosyasıyla çalıştırıp örnek çıktıyı doğrula; test verisini proje içinde bırakma. 901'i bekleyen bir kart değildir; iade hatasının düzelmiş olduğunu varsayma ve iade düzeltmesi hakkında iddiada bulunma.

## Neye dokunma
Proje dosyalarını ve ana dalı değiştirme; yalnız kartın kendi klasöründeki `sonuc.md` dosyasını yaz. Kod, test, README, başka kart veya kart durumu değiştirme. Push, PR veya birleştirme yok.

## Bitti demek
- [ ] Kartın yanında `sonuc.md` var; kullanıcı notu 150–250 kelime (komut/çıktı blokları ve ayrı kanıt paragrafı hariç). Notta veri dosyası ve tarih biçimi açıklanıyor.
- [ ] Notta aynı geçici veri dosyasıyla kitap ekleme, ödünç verme ve gecikenleri listeleme komutları ile doğrulanmış örnek çıktı bulunuyor; çıktı 902'de seçilen biçimle eşleşiyor.
- [ ] Notta iade edilmiş ve henüz gecikmemiş kitapların listelenmediği, boş sonuçta ne görüleceği doğru anlatılıyor; iddialar ana dal koduyla uyuşuyor.
- [ ] `sonuc.md` sonundaki ayrı kanıt paragrafında okunan kaynak yolları, ana dal commit'i, çalıştırılan komutların çıkış kodları ve önce/sonra `git status --porcelain` çıktısı var; proje dosyaları değiştirilmemiş.

## Takılırsan
902'nin birleşmiş özelliği ana dalda yoksa, kod ile README uyuşmuyorsa veya komutları doğrulayamıyorsan durup süper ajana somut engeli bildir; çıktı uydurma.
