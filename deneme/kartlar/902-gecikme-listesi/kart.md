# 902: Geciken açık ödünçleri listele

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: {{PROJE}}

## Ne yapılacak
`python3 -m kitaplik [--veri kayit.json] gecikenler --tarih YYYY-AA-GG` komutunu ekle: yalnız iade edilmemiş ve son teslim tarihi verilen tarihten önce olan ödünçleri, ödünç numarası artan sırada listelesin. Her satır/kayıt ödünç no, kitap kodu, kitap adı, üye, son tarih ve pozitif gecikme günü içersin. Biçimi uygulamadan ÖNCE SendMessage ile süper ajana şu seçenekleri sor ve kullanıcı yanıtını bekle: “Gecikenler çıktısı nasıl olsun? A) Başlıklı, sekmeyle ayrılmış tablo; boşsa ‘Geciken ödünç yok.’ (önerilen, terminalde okunur). B) JSON dizisi; boşsa []; alanlar no, kitap, ad, uye, son_tarih, gecikme_gunu (başka araçlara aktarılır).” Yanıt gelmeden varsayım yapma; süper ajan soruyu kullanıcıya iletsin. Seçilen tek biçimi uygula, kararı `sonuc.md` içine al. Hesabı yeni `kitaplik/listeleme.py` modülünde yap; mevcut iade hatası bu kartın kapsamında değil. Python 3 yalnız `python` adıyla kuruluysa onu kullan.

## Neye dokunma
`kitaplik/islemler.py`, `kitaplik/depo.py` ve mevcut test dosyalarını değiştirme. Yeni davranışı `kitaplik/listeleme.py`, `kitaplik/__main__.py`, yeni `testler/test_gecikenler.py` ve proje `README.md` dosyasıyla sınırla. Listeleme veri dosyasına yazmasın. Yeni bağımlılık, push, PR ve ana dala birleştirme yok.

## Bitti demek
- [ ] `sonuc.md` içinde iki seçenekli karar sorusu ve süper ajandan gelen kullanıcı yanıtı var; CLI yalnız seçilen çıktı biçimini üretiyor, README bu biçimle çalıştırılabilir örnek içeriyor.
- [ ] `python3 -m unittest testler.test_gecikenler` geçiyor: 2026-01-20 için son tarihi 2026-01-15 olan açık kayıt 5 günle listeleniyor; iade edilmiş, son tarihi aynı gün ve gelecekte olan kayıtlar dışlanıyor. Birden çok kayıt no artan sırada ve altı alanın tamamıyla doğrulanıyor.
- [ ] Aynı test komutu boş sonuç için seçilen boş gösterimi, geçersiz tarihte çıkış 1 ve anlaşılır hata mesajını, ayrı CLI sürecinde veri dosyasının baytlarının değişmediğini doğruluyor.
- [ ] `python3 -m unittest` geçiyor; komutlar, çıkış kodları ve çıktılar ile dal, commit ve worktree yolu `sonuc.md` içinde.

## Takılırsan
Çıktı biçimi yanıtı gelmezse uygulamayı beklet ve süper ajana haber ver. Kapsam dışında değişiklik gerekirse veya iş 30 dakikayı geçecekse engeli bildir; kullanıcı yerine karar verme.
