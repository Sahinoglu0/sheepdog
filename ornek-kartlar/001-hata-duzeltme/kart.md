# 001: Boş sayfa parametresinde API hatasını düzelt

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
`api/siparisler.py` içindeki `GET /siparisler` uç noktasını ve `tests/test_siparisler.py` dosyasını incele. Yerel test sunucusunda `curl -i 'http://127.0.0.1:8000/siparisler?sayfa='` komutuyla 500 hatasını değişiklikten önce iki kez üret. Boş değeri sayıya çeviren satır gibi gerçek kök nedeni hata iziyle doğrula; varsayımı sonuç diye yazma. Eksik veya boş `sayfa` değeri 1 kabul edilsin ve 200 dönsün. Pozitif tam sayılar mevcut sayfalama davranışını korusun; `abc`, `0` ve `-1` değerleri 400 ve mevcut hata gövdesini dönsün. Önce boş değer için kırmızı regresyon testi yaz, sonra yalnız parametre doğrulamasını düzelt.

## Neye dokunma
Yalnız `api/siparisler.py` ve `tests/test_siparisler.py` değişebilir. Kimlik doğrulama, veritabanı şeması ve diğer uç noktalar kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Push, PR ve ana dala birleştirme yapma.

## Takılırsan
Hatayı iki denemede üretemezsen, test sunucusu açılamazsa veya 30 dakika dolarsa dur. Komutları ve engeli süper ajana bildir. Mevcut API sözleşmesi boş değer için farklı sonuç istiyorsa kullanıcıya süper ajan üzerinden “boş değeri 1 saymak / 400 ile reddetmek” seçeneklerini sor; cevaba kadar sözleşmeyi değiştirme.

## Bitti demek
- [ ] `sonuc.md` → `Yeniden üretme`: aynı isteğin iki çalıştırmasının komutu, 500 yanıtı ve sır içermeyen hata izi var; `Kök neden` başlığı dosya ve satırı açıklıyor.
- [ ] `python -m pytest tests/test_siparisler.py -k bos_sayfa -q` düzeltmeden önce başarısız, sonra başarılı. Her iki çıktı ve çıkış kodu `sonuc.md` → `Regresyon` içinde.
- [ ] `python -m pytest tests/test_siparisler.py -q` çıkış kodu 0. Eksik, boş, 1, 2, abc, 0 ve -1 durumları testlerde var; komut ve çıktı `sonuc.md` → `Kontroller` içinde.
- [ ] `sonuc.md` → `Teslim`: gerçek başlangıç commit’i, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` ve `git diff <baslangic-commit> HEAD --stat` komutları ile çıktıları var; dal adı, commit hash’i ve worktree yolu belirtilmiş. Değişiklikler yalnız izin verilen dosyalarda ve kendi dalında commit edilmiş.
