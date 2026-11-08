# 010: Araştırmadan kısa karar notu çıkar

Durum: taslak
Tür: icerik
Bekliyor: 008-kaynakli-arastirma
Proje: /notlarinizin/klasörü

## Ne yapılacak
008-kaynakli-arastirma kartı tamamlandıktan sonra onun `kart.md`, `sonuc.md` ve `inceleme.md` dosyalarını oku; kaynak notlarının yerini sonuçtan bul. `arastirma.md` ve `kaynak-kontrol.md` temelinde `karar-ozeti.md` yaz. Beş kişilik ekibin görev takip yaklaşımını seçecek kişiye, başlık ve seçenekler dahil en fazla 150 kelime sun. İhtiyacı bir cümlede anlat, üç seçeneğin birer kazanç ve bedelini ver, gerekçeli tek öneri ve kararı değiştirecek bir koşul ekle. Son cümlede karar sahibinden hangi seçeneği seçmesini istediğini belirt. Öneri kullanıcı kararı değildir; seçilmiş gibi yazma. Yeni araştırma yapma; her olgusal iddia için 008’de doğrulanmış kaynak linkini koru. Özet ile dayanak arasındaki eşlemeyi kartın yanındaki `sonuc.md` içine koy.

## Neye dokunma
Yalnız `karar-ozeti.md` ve bu kartın `sonuc.md` dosyası yazılabilir. Araştırma, kaynak kontrolü, diğer kartlar ve kullanıcı karar kayıtları değiştirilemez. `.env` ve anahtar dosyalarını okuma veya değiştirme. Satın alma, hesap açma veya kararı uygulama kapsam dışı.

## Takılırsan
008 bitmemişse, inceleme sonucu GEÇTİ değilse, kaynak notları yoksa veya 30 dakika dolarsa dur, süper ajana bildir. Araştırma seçim için yetersizse “eksik ölçüt için araştırmayı geri aç / belirsizliği kabul ederek karar iste” seçeneklerini kullanıcıya iletilmek üzere sun. Kullanıcı adına seçim yapma.

## Bitti demek
- [ ] `wc -w karar-ozeti.md` çıktısı en fazla 150; başlık ve seçenekler sayımda. Komut ve çıktı `sonuc.md` → `Uzunluk` içinde.
- [ ] Özette üç seçenek için birer kazanç ve bedel, tek öneri, gerekçe, öneriyi değiştiren koşul ve açık karar sorusu var. İlgili cümleler `sonuc.md` → `İçerik denetimi` içinde eşlenmiş.
- [ ] `sonuc.md` → `Dayanaklar`: 008’in okunan dosya yolları ve inceleme sonucu, özet iddiası → araştırma bölümü → doğrulanmış kaynak linki eşlemesi var; araştırma dışından yeni olgusal iddia eklenmemiş.
- [ ] Kartın yanındaki `sonuc.md` → `Teslim` bölümünde üretilen dosyaların yolları, çalıştırılan denetim komutları, çıktıları ve çıkış kodları var; işçi kart durumunu değiştirmemiş.
