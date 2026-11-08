# 008: Küçük ekip için görev takip seçeneklerini karşılaştır

Durum: taslak
Tür: icerik
Bekliyor: yok
Proje: /notlarinizin/klasörü

## Ne yapılacak
`arastirma.md` dosyasında üç yaklaşımı karşılaştır: git deposunda Markdown kartları, barındırılan kanban hizmeti ve kendi sunucunda çalışan görev panosu. Senaryo: beş kişilik ekip, ayda 200 görev, mevcut git kullanımı, görevleri dışa aktarma zorunluluğu ve ayda en fazla iki saat bakım. Bunlar araştırma varsayımlarıdır; dış kaynaktan doğrulanmış gerçek gibi sunma. Hizmet adları ve başlangıç bağlantıları kart hazır olmadan kullanıcının seçtiği iki adayla doldurulsun. Maliyet, veri dışa aktarma, erişim yetkileri, çevrimdışı çalışma ve bakım yükünü karşılaştır. En az beş birincil kaynak kullan. Her olgusal iddianın hemen yanında bağlantı olsun; her bağlantıyı açıp ilgili metni kontrol et. Kaynak başlığı, URL, erişim tarihi, varsa belge sürümü ve iddiayı destekleyen bölüm adını `kaynak-kontrol.md` içine yaz. Çıkarımları dayanak linkleriyle, varsayımları ayrı etiketle. Sonuç en fazla 800 kelime olsun; karar verme, seçenekleri ve belirsizlikleri sun.

## Neye dokunma
Yalnız `arastirma.md`, `kaynak-kontrol.md` ve kartın yanındaki `sonuc.md` yazılabilir. Diğer notlar, hesap ayarları, satın alma ve dışarıda yayınlama kapsam dışı. `.env` ve anahtar dosyalarını okuma veya değiştirme. Ezberden kaynak, açılmamış link ve doğrulanmamış fiyat yazma.

## Takılırsan
Adaylar veya başlangıç bağlantıları eksikse, internete erişilemiyorsa ya da 60 dakika dolarsa dur, süper ajana bildir. Kaynaklar çelişirse belirsizliği kaydet; ücretli erişim gerekirse “erişilebilir resmî kaynakla kapsamı daralt / araştırmayı beklet” seçeneklerini kullanıcıya süper ajan üzerinden sor. Erişilemeyen kaynağı kontrol edilmiş sayma.

## Bitti demek
- [ ] `arastirma.md` üç yaklaşımı beş ölçütte karşılaştırıyor; `wc -w arastirma.md` sonucu en fazla 800. Komut ve çıktı `sonuc.md` → `Kapsam` içinde.
- [ ] En az beş açılmış birincil kaynak var. `kaynak-kontrol.md` her link için erişim tarihi, bölüm ve desteklediği iddiayı içeriyor; `sonuc.md` → `Kaynak denetimi` bu dosyaya bağlanıyor.
- [ ] Her olgusal iddia yanında destekleyen link var; çıkarım ve varsayım etiketleri ayrı. `sonuc.md` → `İddia denetimi` her iddiayı kaynak-kontrol kaydıyla eşliyor ve erişilemeyen/çıkarılan iddiaları listeliyor.
- [ ] Kartın yanındaki `sonuc.md` → `Teslim` bölümünde üretilen dosyaların yolları, çalıştırılan denetim komutları, çıktıları ve çıkış kodları var; işçi kart durumunu değiştirmemiş.
