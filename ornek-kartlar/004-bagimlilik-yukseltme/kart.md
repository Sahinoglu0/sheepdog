# 004: HTTP istemcisini bir sonraki ana sürüme taşı

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
Bu örnekte `package.json` içindeki `http-istemcisi`, projedeki gerçek HTTP istemci paketinin yer tutucusudur; kart hazır olmadan adı ve kesin kaynak/hedef sürümleri doldurulmalıdır. Mevcut 1.x sürümünden onaylanmış 2.x sürümüne geçişi `package.json`, `package-lock.json`, `src/istemci.ts` ve `tests/istemci.test.ts` ile sınırla. Önce `npm ci` ve `npm test -- --run` ile başlangıç durumunu kaydet. Resmî sürüm notlarını ve geçiş rehberini aç; istek kurma, zaman aşımı, hata nesnesi ve yeniden deneme davranışındaki kırıcı değişiklikleri kullanım yerleriyle eşleştir. Yalnız hedef paketi ve onun zorunlu geçişli bağımlılıklarını güncelle. Uyarlamadan sonra temiz kurulum, test ve derlemeyi çalıştır. Geri alma ölçütü: aynı ortamda başlangıçta geçen bir testin düşmesi, zaman aşımı/yeniden deneme sözleşmesinin korunamaması veya desteklenen çalışma zamanı uyumsuzluğu. Bu durumda teslimi durdur; önceki manifest, kilit ve istemci değişikliklerini birlikte geri alma planını yaz.

## Neye dokunma
Listelenen dört dosya dışı, başka paketlerin toplu güncellenmesi, çalışma zamanı ana sürümü ve CI yapılandırması kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Push, PR ve ana dala birleştirme yapma. Geri alma için reset veya geçmişi yeniden yazma yapma.

## Takılırsan
Yer tutucu/sürüm seçimi çözülmemişse, resmî notlara erişilemiyorsa ya da 60 dakika dolarsa dur. Çalışma zamanı yükseltmesi veya davranış değişikliği gerekirse “yükseltmeyi ertele / ayrı uyumluluk kartı aç” seçeneklerini süper ajana ilet; kullanıcı kararını bekle. Geri alma ölçütü oluştuysa başarısız komutu da bildir; testi gevşetme.

## Bitti demek
- [ ] `sonuc.md` → `Sürüm ve kaynaklar`: eski/yeni kesin sürüm, açılan resmî bağlantılar, erişim tarihi ve her kırıcı değişikliğin ilgili dosyası veya uygulanmama gerekçesi var.
- [ ] `npm ci`, `npm test -- --run` ve `npm run build` çıkış kodları 0; başlangıç ve yükseltme sonrası komut/çıktılar `sonuc.md` → `Kontroller` içinde. Zaman aşımı, hata ve yeniden deneme testlerinin adları belirtilmiş.
- [ ] `git diff <baslangic-commit> HEAD -- package.json package-lock.json` çıktısı ve geçişli paket değişikliklerinin gerekçeleri `sonuc.md` → `Bağımlılık farkı` içinde; alakasız paket güncellemesi yok.
- [ ] `sonuc.md` → `Geri alma`: ölçütlerin her biri için gerçekleşti/gerçekleşmedi kanıtı, önceki kesin sürüm ve dosyaları birlikte geri getirme adımları var. Ölçüt gerçekleşmişse iş bitti sayılmıyor.
- [ ] `sonuc.md` → `Teslim`: gerçek başlangıç commit’i, `git branch --show-current`, `git rev-parse HEAD`, `git status --short` ve `git diff <baslangic-commit> HEAD --stat` komutları ile çıktıları var; dal adı, commit hash’i ve worktree yolu belirtilmiş. Değişiklikler yalnız izin verilen dosyalarda ve kendi dalında commit edilmiş.
