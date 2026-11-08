# 007: Sipariş listesindeki tekrarlanan sorguları azalt

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
`depolar/siparisler.py` içindeki `siparisleri_listele` fonksiyonunda her sipariş için ayrı müşteri sorgusu yapılıp yapılmadığını ölç. Yalnız yerel test verisi kullan. `tests/test_siparisler_performans.py` içinde 100 müşteri ve toplam 1000 siparişlik sabit veri kur; müşteri adı içeren ilk 100 siparişi getir. Sorgu sayacını veri hazırlığından sonra başlat; bağlantı hazırlığını ölçüme katma. Aynı ortamda üç ısınma ve on ölçüm çalıştır; her koşunun süre ve SQL sayısını kaydet. Sonra toplu yükleme veya mevcut ORM ilişki yüklemesiyle tekrar eden sorguları kaldır. Filtre, sıralama, sayfalama, müşteri adı ve dönen kayıtlar değişmesin. Ölçüm testi süreleri ve sorgu sayılarını yazdırsın; önce/sonra aynı komutu kullan.

## Neye dokunma
Yalnız `depolar/siparisler.py` ve belirtilen performans test dosyası değişebilir. Şema, indeks, önbellek, üretim veritabanı ve altyapı ayarları kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Push, PR ve ana dala birleştirme yapma.

## Takılırsan
Başlangıç ölçümünde sorun üretilemiyorsa, ölçümler kararsızsa veya 60 dakika dolarsa dur; ham sayıları süper ajana gönder. İndeks/şema ya da önbellek gerekiyorsa “ayrı indeks kartı / sorgu tasarımını yeniden değerlendirme” seçeneklerini kullanıcıya süper ajan üzerinden sor. Hedefe erişmek için veri boyutunu küçültme.

## Bitti demek
- [ ] `python -m pytest tests/test_siparisler_performans.py -q -s` komutunun önce/sonra çıktıları `sonuc.md` → `Ölçüm` içinde; veri sayısı, veritabanı sürümü, üç ısınma ve on ölçüm ayrı belirtilmiş.
- [ ] İlk 100 sipariş için SQL sayısı en fazla 3; on ölçümün medyan süresi başlangıca göre en az %30 azalmış. Ham süreler, medyanlar ve `(once-sonra)/once*100` hesabı `sonuc.md` → `Karşılaştırma` içinde; hedef tutmadıysa iş bitti sayılmıyor.
- [ ] `python -m pytest tests/test_siparisler.py tests/test_siparisler_performans.py -q -s` çıkış kodu 0; komut/çıktı ve önce/sonra aynı beklenen kayıtları, sıralamayı ve alanları doğrulayan testler `sonuc.md` → `Davranış` içinde.
- [ ] `sonuc.md` → `Teslim`: gerçek başlangıç commit’i, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` ve `git diff <baslangic-commit> HEAD --stat` komutları ile çıktıları var; dal adı, commit hash’i ve worktree yolu belirtilmiş. Değişiklikler yalnız izin verilen dosyalarda ve kendi dalında commit edilmiş.
