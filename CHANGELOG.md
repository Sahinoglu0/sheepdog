# Değişiklik günlüğü

## v0.4: ekip sürümü

- `ana-dal.sh`: ana dal adı otomatik bulunur (origin/HEAD, çıkış yapılmış dal, main, master). `birlestirme-hazirla.sh` ve birleştirici artık `main` varsaymaz.
- `tur.sh`: geri gönderme turu `.gecmis` kaydından sayılır; üç tur sınırı Sheepdog'un hafızasına bağlı kalmaz.
- Oturumlara `--add-dir` olarak artık tüm merkez değil yalnız kendi kart klasörü verilir; işçi `ayarlar.sh`, `roller/` ve diğer kartları yazamaz.
- `baslat.sh`: model ve efor değerleri doğrulanır (`ayarlar.sh` ya da karttan gelen bozuk değer oturum açmaz); `Proje: ~/...` yolu açılır.
- `gozcu.sh`: `claude agents` bir kez başarısız olunca yönetici uyandırılmaz, art arda üç hatada rapor verilir.
- `pano.sh`: `Bekliyor:` birden çok kartı virgülle kabul eder.
- Proje **Sheepdog** adıyla yeniden adlandırıldı (ajan `sheepdog`, ortam değişkeni `SHEEPDOG_KURU`); İngilizce ana sayfa, Türkçe `README.tr.md`.
- `sheepdog`: tek giriş komutu (`board`, `watch`, `ready`, `start`, `set`, `rounds`, `timeline`, `policy`, `new`, `doctor`, ...).
- `sheepdog policy ask|auto`: kalıcı "birleştirmeden önce sor" anahtarı (`.politika`); süper ajan her birleştirici başlatmadan önce okur.
- `sheepdog timeline`: kart başına durum süreleri (`.gecmis`).
- `sheepdog new`: kart iskeleti açar (numara otomatik).
- Yeni belgeler: `docs/ARCHITECTURE.md`, `docs/GLOSSARY.md`, `docs/USAGE.md`, `CONTRIBUTING.md`, `SECURITY.md`, issue/PR şablonları; yeni görseller (akış, kart yaşam döngüsü).
- Tam iki dilli (İngilizce ve Türkçe): betik mesajları, rol istemleri (`roller/en`, `roller/tr`), yönetici ajan (`sheepdog`, `sheepdog-tr`), kart yetenekleri (`/job-card`, `/is-karti`), İngilizce deneme projesi (`deneme/en`, `kur.sh --lang`), İngilizce örnek kartlar (`examples/`), belgeler. Kart alanları, durum adları ve rol adları iki dilde de kabul edilir (`dil.sh`). Dil: `./sheepdog lang en|tr` ya da `SHEEPDOG_LANG`.
- Duman testi 235 kontrole çıktı.

## v0.3: kolay kullanım

- `deneme/`: kendi projenize dokunmadan 10 dakikalık deneme. `bash deneme/kur.sh <hedef>` hatası ve eksik özelliği olan küçük bir proje kurar, 901-903 kartlarını hazırlar.
- `ornek-kartlar/`: 10 detaylı örnek kart (hata, özellik, test, bağımlılık, yeniden düzenleme, belge, performans, araştırma, veri raporu, bağımlı karar özeti) ve kart yazma rehberi.
- `ayarlar.sh`: rol başına model ve efor; `PROFIL=ekonomik|dengeli|guclu`; kartta `Model:` ve `Efor:` ile tek işin işçisine özel model.
- `docs/USAGE.tr.md`: yedi adım adım iş akışı, rol-model tablosu, Sheepdog'a kısa cümleler.
- `SHEEPDOG_KURU=1`: `baslat.sh` oturum açmadan çalıştıracağı komutu gösterir.
- Duman testi 169 kontrole çıktı.

## v0.2: Linux, macOS ve Windows

- Betikler macOS (kendi bash 3.2 sürümü dahil) ve Windows Git Bash'te çalışır; GitHub otomatik kontrolü üç sistemde koşar.
- `guven.py`: güven onayı kontrolü tek yerde; yollar her sistemde normalleştirilir. Git deposunda klasörün kendisi ya da git kökü onaylı olmalı.
- `kontrol.sh`: `python3` ya da `python`, git 2.38 ve Claude Code sürüm kontrolü `sort -V` olmadan.
- `pano.sh`: özet satırı, tıkanan kart uyarısı, `--izle` ile canlı tablo.
- Satır sonları `.gitattributes` ile LF'e sabitlendi (Windows'ta betikler bozulmaz).
- Duman testi 58 kontrole çıktı: sahte `claude` ile sürüm kontrolü ve güven kontrolü dahil.

## v0.1: deneysel ilk sürüm

Claude Code 2.1.293 ile Linux'ta denendi. Parçalar:

- Ajanlar: Sheepdog (`.claude/agents/sheepdog.md`); işçi, incelemeci, doğrulayıcı ve birleştirici rolleri (`roller/`).
- İş kartı yazdıran yetenek: `/is-karti` (`.claude/skills/is-karti/`).
- Programlar (model harcamaz): `pano.sh` (kart durumları), `gozcu.sh` (oturum gözcüsü), `birlestirme-hazirla.sh`.
- Yardımcılar: `baslat.sh` (arka plan oturumu açar), `durum.sh` (kart durumunu değiştirir).
- Örnek kartlar: `ornek-kartlar/`.
- `isler/` klasörü (kartların yeri; içeriği git'e girmez).
