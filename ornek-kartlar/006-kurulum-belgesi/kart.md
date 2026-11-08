# 006: Kurulum belgesini temiz ortamda çalıştırarak düzelt

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
Python tabanlı örnek projenin kök `README.md` dosyasındaki kurulum ve ilk çalıştırma adımlarını doğrula. Başlangıç commit'ini kaydet; izlenen dosyaları `git archive HEAD` ile yeni bir geçici klasöre çıkar. Orada `python3 -m venv .venv` ile boş ortam kur; kullanıcı site paketleri ve mevcut proje ortamını kullanma. Belgede yazan kurulum komutlarını sırayla, aynen çalıştır. Başarısız adımın nedenini bulup yalnız README içindeki komutu veya eksik önkoşulu düzelt. Bu örneğin başarılı akışı `.venv/bin/python -m pip install -r requirements.txt`, `.venv/bin/python -m pytest -q` ve `.venv/bin/python -m api` ile açılan yerel sunucuda `curl -i http://127.0.0.1:8000/saglik` komutudur; son istek 200 ve `{"durum":"ok"}` dönmelidir. Düzeltmelerden sonra düzeltilmiş README ile ikinci, boş bir geçici ortamda tüm akışı baştan doğrula; kendi başlattığın sunucuyu kapat.

## Neye dokunma
Hedef projede yalnız kök `README.md` değişebilir. Uygulama, bağımlılık dosyaları, CI ve kullanıcıya ait mevcut ortamlar kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Gerçek servis veya üretim verisi kullanma. Push, PR ve ana dala birleştirme yapma.

## Takılırsan
Kurulum sır ya da ücretli servis istiyorsa, uygulama hatası çıkarsa, ağ erişimi yoksa veya 45 dakika dolarsa dur. “Sırsız yerel deneme yolu / ayrı yapılandırma kartı” seçeneklerini süper ajana ilet, kullanıcı kararını bekle. Çalıştırılmayan adımı doğrulandı diye işaretleme.

## Bitti demek
- [ ] `sonuc.md` → `Temiz ortam`: iki geçici klasörün yolu, başlangıç commit’i, işletim sistemi, Python/pip sürümleri ve ortam oluşturma komutlarının çıktıları var.
- [ ] `sonuc.md` → `Adım günlüğü`: README adım sırasıyla bütün komutlar, çıkış kodları, ilk hatalar ve düzeltme nedenleri var; ikinci ortamda kurulum ve test komutları çıkış kodu 0.
- [ ] `sonuc.md` → `İlk çalıştırma`: sunucu başlatma/kapatma komutları ve sağlık isteğinin 200 ile beklenen gövdeyi verdiği çıktı var; README’deki her adımın ikinci ortamda çalıştırıldığı gösterilmiş.
- [ ] `sonuc.md` → `Teslim`: gerçek başlangıç commit’i, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` ve `git diff <baslangic-commit> HEAD --stat` komutları ile çıktıları var; dal adı, commit hash’i ve worktree yolu belirtilmiş. Değişiklikler yalnız izin verilen dosyalarda ve kendi dalında commit edilmiş.
