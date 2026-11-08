# 10 dakikalık deneme

Kendi projenize dokunmadan süper ajanın iş dağıtmasını, karar sormasını,
bağımsız incelemeyi, testleri, birleştirmeyi ve bağımlı kartı deneyin.
Hazır Python kitaplık projesi ve üç kart içerir. Kurulum birkaç saniye sürer;
oturumların toplam süresi model yanıtlarına ve kararınıza göre değişir.

Kitin gereksinimleri hazır olmalı: Bash (macOS 3.2 ve Windows Git Bash dahil),
git 2.38+, Python 3.8+ (`python3` veya `python`) ve arka plan oturumlarını
destekleyen Claude Code. Kurucu Claude çalıştırmaz; denemeyi başlatınca ajan
oturumları hesabınızın kullanım limitinden harcar.

## Kurulum ve başlatma

Kitin kökünde, kendi projelerinizden ayrı yeni bir hedef seçin. Boşluk içeren
yolları tırnak içine alın. Örneğin kitin kardeşi bir klasör:

```bash
bash deneme/kur.sh "../kitaplik-denemesi"
```

Hedef yoksa oluşturulur; varsa tamamen boş olmalıdır (gizli dosyalar dahil).
Proje kopyalanır, `main` dalında ilk commit atılır. Global git kimliğiniz yoksa
yalnız bu yeni depoya `deneme <deneme@example.invalid>` kimliği yazılır;
global ayarlar değişmez. Kurucu merkezin `isler/` klasörüne 901, 902 ve 903
kartlarını `hazir` olarak kurar, proje yollarını mutlak yola çevirir.
Hedef doluysa veya aynı adlı kartlardan biri varsa yazmaya başlamadan durur.
Hiçbir şey silmez. Beklenmedik bir disk/git hatasında kısmi kurulum kalabilir;
hata çıktısını ve klasörleri inceleyin, betik otomatik temizlik yapmaz.

Kurucunun yazdığı sırayı izleyin:

1. Hedefte bir kez `claude` açın, güven onayını verin ve oturumdan çıkın.
2. Merkeze dönün ve `claude --agent super-ajan --name super-ajan --permission-mode auto` çalıştırın.
3. **“hazır kartları başlat”** yazın. Merkezde başka hazır kartlarınız varsa bu
   istek onları da başlatabilir; yalnız denemeyi çalıştırmak için talebi
   **“yalnız 901-iade-hatasi, 902-gecikme-listesi ve ardından 903-kullanim-notu kartlarını başlat”** diye sınırlandırın.
4. Merkezde ayrı bir terminalde `./pano.sh --izle` çalıştırın.

Birleştirmeden önce onay isterseniz başlatma mesajınıza “birleştirmeden önce sor” ekleyin.

## Kartlar neyi gösterir?

| Kart | Gösterdiği adım | Beklenen sonuç |
|---|---|---|
| 901-iade-hatasi | Hatayı üretme, regresyon testi, inceleme ve doğrulama | Erken iadede negatif gecikme sıfıra döner; testli düzeltme ana dala girer. |
| 902-gecikme-listesi | Ayrı işçiye dağıtım ve kullanıcı kararı | Süper ajan tablo/JSON seçeneklerini sorar; seçtiğiniz biçimde `gecikenler` komutu ana dala girer. |
| 903-kullanim-notu | Bağımlı içerik kartı ve inceleme | 902 bitince başlar; `isler/903-kullanim-notu/sonuc.md` kullanıcı notu olur. Kod birleştirmesi yapılmaz. |

İlk iki kart bağımsız başlayabilir ve ayrı dosyalara ağırlık verir. Aynı projeye
birleştirmeler sırayla yapılır. 903 başlangıçta hazır görünür ama
`./pano.sh --baslayabilir` çıktısında bulunmaz; 902 bitince listelenir.

## Başlangıçta ve bittiğinde

Hedefte başlangıç kontrolü:

```bash
python3 -m unittest
python3 -m kitaplik gecikme --son-tarih 2026-01-15 --iade-tarihi 2026-01-01
```

8 test geçer ama ikinci komut `Gecikme: -14 gün` yazar. Bu, bilerek bırakılmış
gerçek hatadır; başlangıç testleri erken iadeyi kapsamıyor. Komut veri dosyası
oluşturmaz. Windows'ta Python 3 yalnız `python` adıyla varsa komutlarda onu kullanın.

Deneme tamamlandığında panoda üç kart `bitti` olmalı. Hedefte aynı test komutu
yeni testlerle geçmeli; hatayı üreten komut `Gecikme: 0 gün` yazmalı ve
`python3 -m kitaplik gecikenler --tarih 2026-01-20` çalışmalı. Veri yoksa
seçiminize göre `Geciken ödünç yok.` veya `[]` görünür. Kart klasörlerinde
sonuç ve inceleme kanıtları, kod kartlarında doğrulama ve birleşme raporları
bulunur. `git log --oneline` ana dala giren değişiklikleri gösterir.

Deneme deposu, kartlar ve işçi worktree'leri incelemeniz için kalır; otomatik
silme veya push yapılmaz. Yeniden denemek için ayrı bir kit kopyası ve yeni
boş bir hedef kullanın; mevcut kartların üzerine yazılmaz.
