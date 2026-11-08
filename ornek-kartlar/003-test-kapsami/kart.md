# 003: İndirim hesaplayıcısının mevcut davranışını test et

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
Test edilmemiş `servisler/indirim.py` modülündeki `indirim_hesapla(tutar_kurus, oran, ust_sinir_kurus)` fonksiyonunu incele. Yalnız `tests/test_indirim.py` dosyasında mevcut davranışı sabitleyen testler yaz. Normal oran, sıfır tutar, sıfır oran, üst sınırın altı/eşiti/üstü, yuvarlama sınırı, negatif girdi ve geçersiz tür durumlarını kapsa. Beklenen değerleri mevcut kod ve çağrı noktalarından çıkar; testte aynı algoritmayı kopyalayarak hesaplama. Her sınır için somut giriş ve sabit beklenen değer ya da istisna türü kullan. Önce `python -m pytest --cov=servisler.indirim --cov-branch --cov-report=term-missing -q`, sonra aynı komutla ölçüm al. Eksik test aracı varsa bağımlılık eklemeden engeli bildir.

## Neye dokunma
Yalnız `tests/test_indirim.py` değişebilir. Üretim kodu, test yapılandırması, bağımlılık dosyaları ve diğer modüller kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Push, PR ve ana dala birleştirme yapma.

## Takılırsan
Mevcut davranış belgeyle çelişirse düzeltme yapma; “mevcut davranışı testte belgelemek / ayrı hata kartı açmak” seçeneklerini süper ajana ilet, kullanıcı kararını bekle. Beklenen sonucu belirleyemiyorsan veya 45 dakika dolarsa dur; belirsiz girdiyi ve gözlenen çıktıyı bildir.

## Bitti demek
- [ ] `sonuc.md` → `Davranış tablosu` içinde sayılan dokuz durumun girdisi, sabit beklenen sonucu ve test adı var; istisna durumları açıkça ayrılmış.
- [ ] `python -m pytest --cov=servisler.indirim --cov-branch --cov-report=term-missing -q` çıkış kodu 0; modülün satır ve dal kapsamı en az %90. Önce/sonra sayıları ve tam çıktı `sonuc.md` → `Kapsam` içinde.
- [ ] `python -m pytest -q` çıkış kodu 0; komut ve çıktı `sonuc.md` → `Regresyon` içinde. `git diff --name-only <baslangic-commit> HEAD` çıktısı yalnız izin verilen test dosyasını gösteriyor; gerçek başlangıç hash’i ve çıktı `Kapsam sınırı` içinde.
- [ ] `sonuc.md` → `Teslim`: gerçek başlangıç commit’i, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` ve `git diff <baslangic-commit> HEAD --stat` komutları ile çıktıları var; dal adı, commit hash’i ve worktree yolu belirtilmiş. Değişiklikler yalnız izin verilen dosyalarda ve kendi dalında commit edilmiş.
