# 002: Filtrelenmiş sipariş listesini CSV olarak indir

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
`api/siparisler.py` ve `tests/test_siparisler_csv.py` üzerinde çalış. Mevcut liste sorgusunu kullanarak `GET /siparisler.csv?durum=tamamlandi` uç noktasını ekle. Yerel test sunucusunda `curl -i 'http://127.0.0.1:8000/siparisler.csv?durum=tamamlandi'` ile kontrol et. Çıktı yalnız mevcut kullanıcının erişebildiği, filtreyle eşleşen tüm siparişleri kapsasın; ekran sayfasıyla sınırlı olmasın. Sütun sırası `id,tarih,durum,toplam_kurus`, sıralama artan `id` olsun. UTF-8, virgül ayırıcı, CRLF satır sonu ve standart CSV kaçışı kullan; para tam sayı kuruş olsun. Yanıt 200, `Content-Type: text/csv; charset=utf-8` ve `Content-Disposition: attachment; filename="siparisler.csv"` taşısın. Boş listede yalnız başlık dönsün. Metin hücresi =, +, - veya @ ile başlıyorsa başına tek tırnak ekle. Yeni bağımlılık ekleme; standart CSV yazıcısını kullan.

## Neye dokunma
Yalnız belirtilen uç nokta ve CSV test dosyası değişebilir. Arayüz, şema, mevcut JSON yanıtı ve erişim kuralları kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Push, PR ve ana dala birleştirme yapma.

## Takılırsan
Tüm kayıtları üretmek mevcut altyapıda güvenli değilse tasarım seçme: süper ajana “akış halinde indirme / kayıt sınırı / arka planda dosya üretme” seçeneklerini maliyet ve kullanıcı etkisiyle ilet; kullanıcı kararını bekle. Mevcut altyapı yeterliyse uygulamaya devam et. Erişim filtresi belirsizse veya 60 dakika dolarsa dur, kalan işi bildir.

## Bitti demek
- [ ] `python -m pytest tests/test_siparisler_csv.py -q` çıkış kodu 0. Filtre, sıralama, başlıklar, boş liste ve en az iki sayfalık veri testleri var; komut ve çıktı `sonuc.md` → `CSV sözleşmesi` içinde.
- [ ] Türkçe karakter, virgül, çift tırnak, satır sonu ve formül başlangıçları içeren test verisi CSV okuyucusuyla geri okunuyor; beklenen hücre değerleri test ediliyor. Kanıt `sonuc.md` → `CSV kaçışı` içinde.
- [ ] Başka kullanıcının siparişi dışa aktarılmıyor; kimliksiz istek mevcut erişim hatasını alıyor. `python -m pytest tests/test_siparisler.py tests/test_siparisler_csv.py -q` çıktısı ve çıkış kodu 0, `sonuc.md` → `Yetki ve regresyon` içinde.
- [ ] `sonuc.md` → `Teslim`: gerçek başlangıç commit’i, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` ve `git diff <baslangic-commit> HEAD --stat` komutları ile çıktıları var; dal adı, commit hash’i ve worktree yolu belirtilmiş. Değişiklikler yalnız izin verilen dosyalarda ve kendi dalında commit edilmiş.
