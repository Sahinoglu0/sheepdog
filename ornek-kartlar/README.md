# Örnek kartlar ve kart yazma rehberi

Bu kartlar uyarlanacak taslaklardır. Dosya adları, uç noktalar, test komutları, sürümler ve sayısal hedefler örnek proje sözleşmeleridir; mevcut projenizde doğrulanmış bilgi sayılmaz. Kartlarda geçen işleri bu kit üzerinde çalıştırmayın. Her kart tek bir teslimi ve o teslimin bağımsız olarak nasıl kontrol edileceğini anlatır.

| Klasör | Tür | Ne öğretir? |
|---|---|---|
| [001-hata-duzeltme](001-hata-duzeltme/kart.md) | kod | Hatayı iki kez üretmek, kök nedeni kanıtlamak, kırmızı/yeşil regresyon testi yazmak. |
| [002-csv-disa-aktarma](002-csv-disa-aktarma/kart.md) | kod | Çıktı sözleşmesi, erişim sınırı ve tasarım kararı eşiği belirlemek. |
| [003-test-kapsami](003-test-kapsami/kart.md) | kod | Üretim davranışını değiştirmeden sınır durumlarını test etmek. |
| [004-bagimlilik-yukseltme](004-bagimlilik-yukseltme/kart.md) | kod | Ana sürüm geçişini resmî notlar, uyumluluk testleri ve geri alma ölçütleriyle sınırlamak. |
| [005-guvenli-duzenleme](005-guvenli-duzenleme/kart.md) | kod | Önce mevcut davranışı testle sabitlemek, sonra fonksiyonu bölmek. |
| [006-kurulum-belgesi](006-kurulum-belgesi/kart.md) | kod | Belge komutlarını temiz ortamda gerçekten çalıştırmak. |
| [007-sorgu-performansi](007-sorgu-performansi/kart.md) | kod | Aynı veri ve ortamla önce/sonra süre ve sorgu sayısı ölçmek. |
| [008-kaynakli-arastirma](008-kaynakli-arastirma/kart.md) | icerik | Her iddiayı açılıp kontrol edilmiş kaynakla eşlemek. |
| [009-haftalik-veri-raporu](009-haftalik-veri-raporu/kart.md) | icerik | CSV satırlarını denetlemek, toplamları bağımsız hesapla doğrulamak. |
| [010-karar-ozeti](010-karar-ozeti/kart.md) | icerik | Bağımlı karttan en fazla 150 kelimelik, seçenekli karar notu üretmek. |

## Bir kartı kendi projenize uyarlama

1. Tek bir sonuç seçin. Örneği kit kökünden `mkdir -p isler` ve `cp -R ornek-kartlar/001-hata-duzeltme isler/001-hata-duzeltme` ile kopyalayın. Hedef zaten varsa üzerine kopyalamayın; kullanılmayan bir numara seçin. Klasörü `NNN-kisa-ad` biçiminde, küçük ASCII harflerle adlandırın; başlıktaki numarayı da güncelleyin.
2. `Proje:` değerini işin yapılacağı gerçek mutlak klasörle değiştirin. Kod kartında bu klasör bir git deposu olmalıdır. Kitin kart klasörü ile hedef projenin klasörü farklı olabilir.
3. Dosyaları ve mevcut sözleşmeyi okuyun. Örnek modül adlarını, test komutlarını, sunucu başlatma yolunu, test verisini ve beklenen yanıtları gerçek projeye göre değiştirin. Komutların önkoşullarını yazın. 004 için gerçek paket adını, kesin eski/yeni sürümleri ve resmî geçiş bağlantılarını; 008 için iki adayın adlarını ve başlangıç bağlantılarını doldurun. 009 için tarih aralığı, sütunlar ve para birimini doğrulayın. `<baslangic-commit>` gibi çalışma sırasında belirlenecek kanıt alanları gerçek değerle raporlanır; yer tutucu komut aynen çalıştırılmaz.
4. İzin verilen dosyaları ve kapsam dışını yazın. Süre sınırını, durma nedenlerini ve kullanıcı kararı gerektiren seçenekleri belirleyin. Başlangıçta bilinen ürün kararlarını kart hazır olmadan çözün; çalışma sırasında yeni karar çıkarsa işçi süper ajana seçenekleriyle sorar.
5. Bağımlılık yoksa `Bekliyor: yok` bırakın. Karar özeti için hem 008 hem 010 kartını kopyalayın; 010'un `Bekliyor:` değeri 008'in gerçek klasör adıyla aynı olsun. Yeniden adlandırırsanız metin içindeki kart yollarını da düzeltin. Kaynak raporlarının proje içindeki konumlarını açık yazın.
6. Her kabul maddesine komut, beklenen sonuç ve kanıt yeri ekleyin. Kod kartı için dal, commit ve worktree yolunu isteyin. İçerik kartı için kaynak denetimi veya hesap doğrulaması isteyin. Belge değişikliği git dalında test edilip birleştirilecekse 006 gibi `Tür: kod` kullanın.
7. Kartı `Durum: taslak` olarak gözden geçirin. Kullanıcı onayından sonra kit kökünde `./durum.sh isler/001-hata-duzeltme hazir` çalıştırın. `./pano.sh --baslayabilir` ile hazır ve bağımlılığı bitmiş kartları görün. İşçi kart durumunu değiştirmez.

## Biçim sözleşmesi

Alan adlarını değiştirmeyin; satır başına girinti, madde işareti veya kalın yazı eklemeyin. `pano.sh` alanları `sed -n "s/^Alan: //p"` biçiminde okur. Dört alanın her biri yalnız bir kez yazılır. `Tür` yalnız `kod` veya `icerik` olabilir. Bölümler bu örneklerde aşağıdaki sıradadır:

```markdown
# 001: Kısa ve somut başlık

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
Hedef dosya, başlangıç komutu, girdi ve beklenen davranış.

## Neye dokunma
İzin verilen sınır, kapsam dışı dosyalar ve yasak işlemler.

## Takılırsan
Durma nedeni, süre sınırı ve süper ajana iletilecek karar seçenekleri.

## Bitti demek
- [ ] Somut çıktı, doğrulama komutu ve sonuc.md içindeki kanıt yeri.
- [ ] Mevcut davranışı koruyan kontrol ve sonuc.md içindeki çıktısı.
- [ ] Teslim dosyaları; kod işinde dal, commit ve worktree kanıtı.
```

İşçi sonucu **kartın yanındaki** `sonuc.md` dosyasına yazar. Kartta belirtilen rapor veya uygulama dosyaları ise `Proje:` klasörüne göre konumlandırılır. `sonuc.md` içindeki dosya yolları incelemecinin bunları bulmasına yetmelidir. Her komut için çalışma klasörü, komut, çıkış kodu ve ilgili çıktı bulunur. Uzun çıktılar ek dosyaya konursa sonuçtan göreli bağlantı verilir. Sır içeren çıktılar rapora alınmaz; gerekli maskeleme belirtilir. Çalıştırılamayan kontrol başarı değildir, engel olarak yazılır.

İşçi kodu kendi worktree dalında commit eder; push, PR veya ana dala birleştirme yapmaz. Bittiğinde ya da takıldığında süper ajana sonucu ve dosya yerini tek cümleyle bildirir. İncelemeci kabul maddelerini ve kanıtları değerlendirir. Kod kartında doğrulayıcı komutları yeniden çalıştırır; birleştirici proje kuralları ve kontroller geçerse birleştirir. İçerik kartı incelemeden sonra biter; kod doğrulama ve birleştirme adımına girmez. Durumu işçi değil, süper ajan `durum.sh` ile yönetir.

## İyi kart kontrol listesi

- [ ] Kart tek bir sonuç üretiyor ve başka bir kişi bu sonucu kontrol edebiliyor mu?
- [ ] Dosya/modül, başlangıç komutu, girdi ve beklenen davranış somut mu?
- [ ] Her “Bitti demek” maddesinde ölçülebilir eşik veya kesin beklenen çıktı var mı?
- [ ] Yazılabilecek dosyalar, kapsam dışı işler ve `.env`/anahtar yasağı açık mı?
- [ ] Kullanıcı kararı gerektiren noktalar ve seçenekler yazılı mı?
- [ ] Süre sınırı ve durup süper ajana bildirme koşulu var mı?
- [ ] Kanıtın `sonuc.md` içinde nerede bulunacağı ve kontrolün nasıl tekrarlanacağı belli mi?
- [ ] Tür, bağımlılık, proje yolu ve kod kartının dal/commit teslimi doğru mu?

## Kötü ve iyi kabul maddeleri

| Kötü “Bitti demek” | İyi “Bitti demek” |
|---|---|
| API iyi çalışıyor. | `python -m pytest tests/test_siparisler.py -q` çıkış kodu 0; boş sayfa için 200, geçersiz metin için 400 test ediliyor; komut/çıktı `sonuc.md` → `Kontroller` içinde. |
| Sorgu hızlandı. | Aynı 1000 siparişle on ölçümün medyan süresi en az %30 azaldı; ham süreler ve hesap `sonuc.md` → `Karşılaştırma` içinde. |
| Araştırma güvenilir. | Her olgusal iddia yanında açılmış kaynak linki var; erişim tarihi ve destekleyen bölüm `kaynak-kontrol.md` içinde, eşleme `sonuc.md` → `İddia denetimi` içinde. |
| Rapor tamam. | Günlük kuruş toplamı doğrudan haftalık toplam ve bağımsız ikinci hesapla eşit; üç sonuç `sonuc.md` → `Çapraz kontrol` içinde. |
