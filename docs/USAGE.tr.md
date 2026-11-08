# Sheepdog kullanım rehberi

Komutları, aksi belirtilmedikçe kitin kök klasöründe çalıştırın. `<hedef>`,
`<proje>` ve `<kart>` yerlerini kendi yollarınızla veya kart klasör adıyla değiştirin;
köşeli parantezleri yazmayın. Kartların `Proje:` alanına mutlak yol yazın.
Windows'ta Git Bash kullanın.

## Başlamadan önce

1. `./kontrol.sh /tam/yol/proje` ile gereksinimleri kontrol edin. Kit Claude Code
   2.1.293 veya sonrasını, `--bg` ve `agents` desteğini, otomatik izin modunu,
   git 2.38+ ve Python 3.8+ bekler. Eksikleri gidermeden iş başlatmayın.
2. Her hedef proje klasöründe bir kez `claude` açıp güven onayını kabul edin.
   Git deposunda yalnız üst klasörün onaylı olması yeterli değildir.
3. Kart hazırlamak için kit kökünde normal `claude` oturumunda
   `/is-karti yapılacak iş` yazın. Soruları cevaplayın, oluşan
   `isler/<kart>/kart.md` dosyasını okuyun. `Proje`, `Tür`, `Bekliyor`,
   kapsam ve ölçülebilir “Bitti demek” maddelerini kontrol edin.
4. Onayladığınız kartı `./durum.sh isler/<kart> hazir` ile hazırlayın.
   Sheepdog'u kit kökünde başlatın:

   ```bash
   claude --agent sheepdog --name sheepdog --permission-mode auto
   ```

   Ardından **“hazır kartları başlat”** yazın. Bir bilgisayarda aynı anda tek
   `sheepdog` oturumu kullanın; işçiler bu ada mesaj yollar.

Sheepdog kartları yönetir; kart yazdırma işi normal oturumdaki `/is-karti`
komutuyla yapılır. Kod kartında akış işçi → incelemeci → doğrulayıcı → prova →
birleştiricidir. İçerik kartı incelemeden geçince biter. Ayrı terminalde
`./pano.sh` ile durumu, `./pano.sh --baslayabilir` ile hazır ve bağımlılığı
bitmiş kartları görebilirsiniz. Sheepdog başlangıçlarda sessiz kalır;
karar gerektiğinde, iş bitince veya tıkanınca haber verir.

## 1. İlk deneme

**Ne zaman:** Gerçek projelerden önce kartların ve ayrı oturumların akışını görmek için.

1. Deneme seti bulunan kit sürümünde, kit kökünden çalıştırın:

   ```bash
   bash deneme/kur.sh <hedef>
   ```

   Boş bir deneme hedefi seçin. Kurucunun çıktısındaki proje ve kart yollarını
   esas alın. `deneme/kur.sh` yoksa önce deneme setini içeren sürüm gerekir.
2. Oluşturulan proje klasöründe `claude` açıp güven onayını kabul edin.
   Kit köküne dönüp `./kontrol.sh <oluşturulan-proje>` çalıştırın.
3. Hazır kartları okuyun; panoda `hazir` olduklarını kontrol edin. Taslak
   bıraktığınız kartları yalnız okuyup onayladıktan sonra `durum.sh` ile hazırlayın.
4. Yukarıdaki komutla Sheepdog'u açın. **“Birleştirmeden önce sor.
   Hazır kartları başlat.”** yazın. Başka terminalde `./pano.sh --izle` çalıştırın.

**Beklenen:** Kartın durumu `calisiyor`, ardından kontrol aşamalarına geçer.
Başarılı kod kartı için birleştirme onayı sorulur; onaydan sonra dal ve ana dal
commit'i bildirilir. Kart klasöründe `sonuc.md`, `inceleme.md`, kod işleri için
`dogrulama.md` ve birleştirme yapıldıysa `birlesme.md` bulunur.

**Dikkat:** Deneme de gerçek model oturumları açar ve kullanım limitinden harcar.
Kurucunun üreteceği klasör adlarını tahmin ederek komut yazmayın.

## 2. Tek projede birkaç hata düzeltmesi

**Ne zaman:** Aynı depoda birbirinden bağımsız birkaç hatayı takip ederken.

1. Normal oturumda örneğin **“/is-karti /tam/yol/proje içinde boş e-postada
   kayıt formu çöküyor; ayrıca arama boş sonuçta eski listeyi gösteriyor.
   Ayrı bitirilebilir kartlar hazırla.”** yazın.
2. Her kartın hatayı üretme adımlarını ve başarı kontrollerini okuyun.
   Birbirine bağımlı değişiklikleri bağımsızmış gibi başlatmayın;
   gerekiyorsa sonraki kartın `Bekliyor:` alanına önceki kartın tam klasör adını yazın.
3. Onaylanan her kart için `./durum.sh isler/<kart> hazir` çalıştırın.
   Sheepdog'a **“hazır kartları başlat”** deyin; `./pano.sh` ile izleyin.

**Beklenen:** Bağımsız işler ayrı işçi oturumlarında ve worktree dallarında yürür.
Aynı projede aynı anda yalnız bir birleştirici çalışır. Birleştirme sırası gelince
prova tekrarlanır; çakışma varsa iş aynı işçiye döner.

**Dikkat:** Kartın “Neye dokunma” alanını dar tutun. Kod deposunda
`.claude/worktrees/` yolunu `.gitignore` içine ekleyin. Kit push yapmaz;
ana dala alınan değişikliği uzaktaki depoya göndermek ayrı bir karardır.

## 3. Farklı projelerde aynı anda ilgisiz işler

**Ne zaman:** Bir projede hata düzeltirken başka bir proje için araştırma veya özellik işi yürütmek için.

1. Her proje için güven onayı verin ve kit kökünden kontrol edin:

   ```bash
   ./kontrol.sh /tam/yol/proje-a /tam/yol/proje-b
   ```

2. Normal oturumda ayrı istekler yazın: **“/is-karti /tam/yol/proje-a içinde
   ödeme toplamı hatasını düzelt”** ve **“/is-karti /tam/yol/proje-b için
   depolama seçeneklerini kaynaklarıyla karşılaştır; yalnız rapor üret”**.
3. İlk kartın `Tür: kod`, rapor kartının `Tür: icerik`, bağımsız kartların
   `Bekliyor: yok` olduğunu kontrol edin. Her kartı onaylayıp `hazir` yapın.
4. Tek Sheepdog'a **“hazır kartları başlat”** yazın. `./pano.sh --izle` açın.

**Beklenen:** Kartlar kendi `Proje:` klasörlerinde ayrı oturumlarla başlar.
İçerik kartı incelemeden geçince biter; kod kartı doğrulama ve birleştirme de görür.

**Dikkat:** Her oturum ayrı limit harcar. Proje yollarını karıştırmayın;
aynı makinede her proje için ayrı Sheepdog açmayın.

## 4. Araştırma → karar özeti → uygulama

**Ne zaman:** Uygulama kapsamı önce araştırmaya ve yazılı bir karara dayanacaksa.

1. Normal oturumda **“/is-karti Bu proje için önce seçenekleri kaynaklarıyla
   araştır, sonra karar özeti çıkar, son olarak seçilen çözümü uygula.
   Üç kartın çıktı dosyalarını ve kabul ölçütlerini belirle.”** yazın.
2. Örneğin kartları aşağıdaki gibi bağlayın. `Bekliyor:` bir veya birden çok kartın
   tam klasör adını alır (birden çoksa virgülle ayırın).

   | Kart klasörü | Tür | Bekliyor |
   |---|---|---|
   | `001-arastirma` | `icerik` | `yok` |
   | `002-karar-ozeti` | `icerik` | `001-arastirma` |
   | `003-uygulama` | `kod` | `002-karar-ozeti` |

3. Sonraki kartın “Ne yapılacak” alanına önceki çıktının açık dosya yolunu
   ve nasıl kullanılacağını yazın. Karar ölçütlerini önceden belirlediyseniz
   üç kartı da onaylayıp `hazir` yapın. Sheepdog'a **“hazır kartları başlat”** deyin.
4. Son seçimi kendiniz yapacaksanız uygulama kartını `taslak` bırakın.
   Özeti okuyup kararınızı karta işletin; sonra
   `./durum.sh isler/003-uygulama hazir` çalıştırıp **“hazır kartları başlat”** deyin.

**Beklenen:** `./pano.sh --baslayabilir` önce yalnız araştırmayı gösterir.
Her `bitti` sonrasında Sheepdog bağımlılığı tamamlanmış hazır kartı başlatır.
Karar gerekirse seçenekleri size iletir ve cevabınızı ilgili oturuma gönderir.

**Dikkat:** `Bekliyor:` yalnız önceki kartın `bitti` olmasını bekler; kullanıcı
onayı yerine geçmez. Karar özeti kartının bitmesi, taslak uygulama kartını otomatik hazırlamaz.

## 5. Temkinli mod: birleştirmeden önce sor

**Ne zaman:** Ana dala girecek her değişikliği ayrıca onaylamak istediğinizde.

1. İşler başlamadan Sheepdog'a **“Birleştirmeden önce sor.
   Hazır kartları başlat.”** yazın.
2. Onay sorusu gelince kartın `sonuc.md`, `inceleme.md` ve `dogrulama.md`
   dosyalarını okuyun; dalı ve gerekirse diff'i kontrol edin.
3. Uygunsa **“001 için birleştirmeyi onaylıyorum”** yazın; uygun değilse
   **“001'i henüz birleştirme; kararımı bekle”** deyin.

**Beklenen:** Prova temizse kart `birlesme-bekliyor` durumuna gelir;
izin vermeden birleştirici başlatılmaz. Onaydan sonra birleşmiş ağaçta testler
çalışır; geçerse ana dal ileri sarılır ve sonuç bildirilir.

**Dikkat:** Bu talimatı birleştirici başlamadan verin. Ayar dosyasında kalıcı
bir temkinli mod anahtarı yoktur; yeni Sheepdog oturumunda tercihinizi yine söyleyin.
İçerik kartları birleştirme aşamasına girmez.

## 6. Bilgisayarı açık bırakıp uzun süre çalıştırmak

**Ne zaman:** Hazır ve kapsamı net işleri uzun bir çalışma süresine bırakırken.

1. Kartları, güven onaylarını ve `./kontrol.sh <proje>` çıktısını kontrol edin.
   Gerekli kararları önceden netleştirin; sonra Sheepdog'a **“hazır kartları başlat”** deyin.
2. Sheepdog ilk oturumu açınca `./gozcu.sh` betiğini arka planda başlatır.
   Gözcü varsayılan olarak 600 saniyede bir bakar; sessizlik sınırı 20 dakikadır.
   Sorun bildirip çıktığında, açık iş kaldıkça Sheepdog onu yeniden başlatır.
3. Başka terminalde `./pano.sh --izle` açın (varsayılan yenileme 10 saniye).
   İzlemeyi bitirmek için bu terminalde Ctrl+C kullanın; bu yalnız panoyu kapatır.
4. Sabah Sheepdog'a **“durum ne”** yazın ve `./pano.sh` çalıştırın.
   `tikandi`, `birlesme-bekliyor` ve hâlâ aktif görünen kartlara bakın;
   Sheepdog'un karar sorularını cevaplayın. Biten kartların raporlarını,
   kod kartlarında `birlesme.md` içindeki testleri ve ana dal commit'ini kontrol edin.

**Beklenen:** Gözcü kapanan, başarısız veya uzun süre hareketsiz görünen
   oturumları Sheepdog'a bildirir. Pano kart durumlarını gösterir.

**Dikkat:** Bilgisayar ve oturumlar açık kalmalı; kapanınca işler durur.
Gözcü tek başına işi yeniden başlatmaz ve pano oturum sağlığını kanıtlamaz.
Bir onay veya karar sorusu cevap bekliyorsa o iş ilerlemeyebilir.

## 7. Takılan ya da geri dönen işi yönetmek

**Ne zaman:** İnceleme/test başarısızsa, ortam engeli varsa veya oturum ilerlemiyorsa.

1. `./pano.sh` çalıştırın; Sheepdog'a **“007'nin durumu ne, neye takıldı?”** yazın.
   Kartın `sonuc.md`, varsa `inceleme.md`, `dogrulama.md` ve `birlesme.md`
   dosyalarındaki kanıta bakın.
2. İncelemeci veya doğrulayıcı işi geri gönderirse bulgular aynı işçiye
   iletilir ve durum `calisiyor` olur. Üç turda geçmezse Sheepdog size sorar.
3. Cevabınızı somut yazın: **“007'nin işçisine ilet: hata yalnız boş sorguda
   oluşuyor; beklenen sonuç boş liste. Şu adımlarla üret: …”** veya gelen karar
   sorusuna **“007 için ikinci seçeneği uygula”** deyin. Sheepdog cevabı aynı oturuma iletir.
4. Birleştirme ortam yüzünden kalırsa durum `tikandi` olur. Ortam sorununu
   giderdikten sonra **“007 için ortam engeli giderildi; mevcut kanıtı ve oturum
   durumunu kontrol et”** deyin. Dal kaynaklı sorunlar aynı işçiye geri gider.

**Beklenen:** Panoda `tikandi` kart için uyarı görürsünüz. Yeniden yapılan
   işin kanıtı güncellenir ve kontroller tekrar değerlendirilir.

**Not:** Tur sayısını `./tur.sh isler/<kart>` verir (`.gecmis` kaydından); sınır Sheepdog'un hafızasına bağlı değildir.
Her gözcü uyarısı kartı otomatik `tikandi` yapmaz. Ölü oturum için otomatik
kurtarma garantisi yoktur. Durumu elle `bitti` yaparak kontrolleri atlamayın;
yeniden açılan işte mevcut dal/worktree bilgisi `sonuc.md` içinde korunmalıdır.

## Hangi rol hangi model?

| Rol | İş | Varsayılan model | Efor | Ne zaman değiştirilir? |
|---|---|---|---|---|
| İşçi (`isci`) | Kartı uygular, kanıt yazar | `sonnet` | `high` | Karmaşık kartta daha güçlü model denenebilir |
| İncelemeci (`reviewer`) | Bağımsız kabul incelemesi | `sonnet` | `high` | Karmaşık diff veya muhakeme gerektiren kabul ölçütlerinde |
| Doğrulayıcı (`dogrulayici`) | Yazılı kontrolleri çalıştırır | `sonnet` | `medium` | Basit kontrollerde ekonomik profil denenebilir |
| Birleştirici (`birlestirici`) | Birleşmiş ağacı test eder, ana dala alır | `sonnet` | `high` | Karmaşık proje kapılarında daha güçlü model denenebilir |
| Sheepdog | Oturumları ve kararları yönetir | `opus` | `high` | Yönetim kararlarının niteliğini izleyerek |
| Gözcü, pano, birleştirme provası | Takip, tablo, çakışma kontrolü | Model kullanmaz | — | Model ayarı yok |

Bu değiştirme önerileri ve `ayarlar.sh` içindeki ekonomik/dengeli/güçlü
profiller ölçülmedi; maliyet veya başarı garantisi değildir.

### Ayar değiştirmek

En kolayı profil seçmek. `ayarlar.sh` içinde tek satırı değiştirin:

```bash
PROFIL=ekonomik   # ya da dengeli (varsayılan) ya da guclu
```

| Profil | İşçi | İncelemeci | Doğrulayıcı | Birleştirici | Ne zaman |
|---|---|---|---|---|---|
| ekonomik | sonnet, medium | sonnet, medium | haiku, medium | sonnet, medium | Kapsamı dar, bitti şartı net işler |
| dengeli | sonnet, high | sonnet, high | sonnet, medium | sonnet, high | Varsayılan |
| guclu | opus, high | opus, high | sonnet, high | opus, high | Karmaşık kod, zor inceleme |

Tek bir rolü profilden bağımsız değiştirmek için `ayarlar.sh` içindeki ikinci bölümde
satırın başındaki `#` işaretini kaldırın (ör. `MODEL_ISCI=opus`). Efor değeri
`low`, `medium`, `high` dışında olursa başlatma açık hata verir.

Yalnız bir kartın işçisini değiştirmek için kart başlığının altındaki alanlara ekleyin:

```text
Model: opus
Efor: high
```

İki alan da isteğe bağlıdır; yalnız yazdığınız alan rol ayarının önüne geçer.
İncelemeci, doğrulayıcı ve birleştirici karttaki bu alanları kullanmaz.
Öncelik: işçi için kart → `ayarlar.sh` → yerleşik varsayılanlar;
diğer roller için `ayarlar.sh` → yerleşik varsayılanlar.
Ayar dosyası yoksa tablodaki dört alt rol varsayılanı kullanılır.
Değişiklikler yalnız yeni başlatmalarda okunur; çalışan oturum değişmez.

Sheepdog için `.claude/agents/sheepdog.md` içindeki `model:` ve `effort:`
satırlarını düzenleyip yeni Sheepdog oturumu başlatın. `ayarlar.sh` onu etkilemez.

Seçimi gerçek oturum açmadan görmek için:

```bash
SHEEPDOG_KURU=1 ./baslat.sh isler/<kart> isci
SHEEPDOG_KURU=1 ./baslat.sh isler/<kart> reviewer
```

Güven onayı bu modda da gereklidir. Çıktı, kartın `Proje:` klasöründe çalıştırılacak
komutun kabuk için kaçışlanmış tek satırıdır. Claude çalışmaz, kart durumu ve
`.gecmis` değişmez. `ayarlar.sh` kabuk dosyası olarak okunur; içine yalnız ayar
atamalarını ve yorumları koyun.

## Sheepdog'la kısa cümleler

- “Hazır kartları başlat.”
- “Durum ne?”
- “Birleştirmeden önce sor.”
- “001 için birleştirmeyi onaylıyorum.” (Onay sorusu geldiğinde.)
- “001'i henüz birleştirme; kararımı bekle.” (Birleştirici başlamadan.)
- “007'nin işçisine şu bilgiyi ilet: …”
- “007 için ikinci seçeneği seçiyorum.” (İletilen karar sorusuna cevap olarak.)

Kitte tanımlı bir “kartı durdur” akışı yoktur. Bir kartı `taslak` yapmak da
çalışan oturumu durdurmaz.
