# 005: Sipariş toplamı fonksiyonunu davranışı koruyarak böl

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
`servisler/siparis.py` içindeki uzun `siparis_toplami` fonksiyonunu incele. Önce `tests/test_siparis_toplami.py` içinde boş sepet, tek/çok kalem, indirim, vergi, kargo eşiğinin iki yanı ve küsurat sınırı için mevcut çıktıları sabitle. Ara değerler yerine dışarıdan gözlenen toplam ve istisnaları test et. Testleri değişiklik öncesinde çalıştırıp ayrı bir commit'e al. Sonra aynı modülde kalem toplamı, indirim ve kargo hesabını özel yardımcı fonksiyonlara çıkar. Dış fonksiyonun imzası, hesap sırası, yuvarlaması ve hata davranışı aynen kalsın. Fonksiyonu en fazla 40 mantıksal satıra indir; boş satır ve yorumları sayma. Yeni mimari veya bağımlılık ekleme.

## Neye dokunma
Yalnız `servisler/siparis.py` ve belirtilen test dosyası değişebilir. Fiyatlandırma kuralları, veritabanı, API ve diğer modüller kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Push, PR ve ana dala birleştirme yapma.

## Takılırsan
Davranışta hata görürsen bu kartta düzeltme. “Mevcut davranışı koru / ayrı hata kartı aç” seçeneklerini süper ajana ilet, kullanıcı kararını bekle. Test edilemeyen yan etki, başka modüle taşıma gereği veya 60 dakika sınırı varsa dur ve somut engeli bildir.

## Bitti demek
- [ ] `python -m pytest tests/test_siparis_toplami.py -q` düzenlemeden önce ve sonra çıkış kodu 0. İki çıktı, aynı test senaryoları ve önceki test commit’i `sonuc.md` → `Davranışı sabitleme` içinde.
- [ ] `sonuc.md` → `Yapısal fark`: dış imzanın önce/sonra hali, çıkarılan yardımcıların görevleri ve ana fonksiyonun en fazla 40 mantıksal satır olduğunu gösteren numaralı kaynak dökümü var.
- [ ] `python -m pytest -q` çıkış kodu 0; komut ve çıktı `sonuc.md` → `Regresyon` içinde. `git diff <test-commit> HEAD -- tests/test_siparis_toplami.py` çıktısı boş; gerçek test commit’i ve çıktı aynı başlıkta.
- [ ] `sonuc.md` → `Teslim`: gerçek başlangıç commit’i, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` ve `git diff <baslangic-commit> HEAD --stat` komutları ile çıktıları var; dal adı, commit hash’i ve worktree yolu belirtilmiş. Değişiklikler yalnız izin verilen dosyalarda ve kendi dalında commit edilmiş.
