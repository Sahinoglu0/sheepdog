# Değişiklik günlüğü

## v0.4: Sheepdog

- `SHEEPDOG_CLAUDE`, `launch.sh` ve `watchdog.sh` içindeki `claude` komutunu geçersiz kılar. Gözcü testi artık bunu kullanıyor; gerçek `claude` kurulu Windows makinelerindeki sahte hatayı giderir (masaüstü koşusundan bildirildi).
- Birleştirme onayı artık zorunlu: politika `ask` iken `launch.sh ... merger` ve `state.sh ... merging`, `./sheepdog approve <kart>` kaydedilene kadar reddedilir (gerçek bir koşuda yönetici sormadan birleştirmişti). Merkezdeki `CLAUDE.md`, orada açılan her oturumu (masaüstü uygulaması dahil) yönetici kurallarına bağlar (önceki uygulama koşuları README'den doğaçlama yapıp aşamaları atlamıştı). Duman testi: 299 kontrol.
- Windows'ta (Git Bash) gerçek oturumlarla ilk uçtan uca koşu: üç deneme kartı mühürlü kanıtlarla inceleme, doğrulama ve birleştirmeden geçti. `doctor`, Windows'ta `CLAUDE_CODE_GIT_BASH_PATH` ayarlı değilse uyarır.
- Aşama kapıları: `state.sh` inceleme, doğrulama ve birleştirmeyi atlamayı reddeder (`seal.sh verdict`; insanlar `SHEEPDOG_GATE=off` kullanabilir). Masaüstü uygulamasındaki gerçek bir deneme koşusunda yöneticinin kartları işçiden hemen sonra `done` yapması üzerine eklendi. İşçi istemlerine Windows'ta `EnterWorktree` hatası için elle worktree yedeği eklendi.
- `seal.sh`: kanıt dosyaları (`result.md`, `review.md`, `verification.md`, `merge.md`) için kurcalama tespiti. Yönetici rol bildirdiğinde her birini SHA-256 ile mühürler; doğrulayıcı, birleştirici ve `done` öncesi kontrol eder; sahte ya da değiştirilmiş kararda kartı `stuck` yapar.
- Lisans Apache-2.0; `NOTICE` içinde dostça bir kredi ricası (ek koşul değil) ve `CITATION.cff`.

- Proje **Sheepdog** adıyla yeniden adlandırıldı; İngilizce ve Türkçe tam iki dilli (README, belgeler, roller, ajanlar, yetenekler, mesajlar, deneme seti, örnek kartlar).
- Bütün dosya, klasör ve komut adları İngilizceleştirildi: `board.sh`, `state.sh`, `launch.sh`, `watchdog.sh`, `dry-run.sh`, `doctor.sh`, `settings.sh`, `main-branch.sh`, `rounds.sh`, `trust.py`, `lang.sh`; `jobs/`, `roles/`, `trial/`, `examples/`, `tests/`; kart dosyaları `card.md`, `result.md`, `review.md`, `verification.md`, `merge.md`. Durum, rol ve kart alanı adları İngilizce asıl adlarla tutulur; Türkçe karşılıkları kabul edilir (`lang.sh`, bkz. `docs/DILLER.md`).
- `sheepdog`: tek giriş komutu (`board`, `watch`, `ready`, `start`, `set`, `rounds`, `timeline`, `policy`, `lang`, `new`, `doctor`, ...).
- `sheepdog policy ask|auto`: kalıcı "birleştirmeden önce sor" anahtarı (`.policy`); yönetici her birleştirici başlatmadan önce okur.
- `sheepdog timeline`: kart başına durum süreleri; `sheepdog new`: kart iskeleti.
- `main-branch.sh`: ana dal adı otomatik bulunur; `dry-run.sh` ve birleştirici artık `main` varsaymaz.
- `rounds.sh`: geri gönderme turu `.history` kaydından sayılır; üç tur sınırı yöneticinin hafızasına bağlı kalmaz.
- Oturumlara yalnız kendi kart klasörü verilir; model ve efor değerleri doğrulanır; `~/` proje yolları açılır.
- `watchdog.sh`: art arda üç `claude agents` hatasında rapor verir. `board.sh`: `Bekliyor:` birden çok kartı kabul eder.
- Tamamen yeni görseller: `tools/build_assets.py` ile üretilen animasyonlu SVG'ler (afiş, akış, yaşam döngüsü, konuşma, mimari, güvenlik; iki dilde).
- Duman testi 289 kontrole çıktı. Bağımsız incelemeden sonra düzeltmeler: `main-branch.sh` açık özellik dalını ana dal sanmaz; `watchdog.sh` beklenmedik JSON'da çökmez; `state.sh` yalnız ilk durum satırını değiştirir ve CRLF'i korur; büyük harfli durumlar kabul edilir; model/efor `-` ile başlayamaz; biten kart için işçi yeniden başlatılmaz; `incelemeci` takma adı çalışır; güven modeli anlatımı `--add-dir`'in yaptığını abartmaz.

## v0.3: kolay kullanım

- `trial/`: kendi projenize dokunmadan 10 dakikalık deneme. `bash trial/setup.sh <hedef>` hatası ve eksik özelliği olan küçük bir proje kurar, 901-903 kartlarını hazırlar.
- `examples/tr/`: 10 detaylı örnek kart (hata, özellik, test, bağımlılık, yeniden düzenleme, belge, performans, araştırma, veri raporu, bağımlı karar özeti) ve kart yazma rehberi.
- `settings.sh`: rol başına model ve efor; `PROFIL=ekonomik|dengeli|guclu`; kartta `Model:` ve `Efor:` ile tek işin işçisine özel model.
- `docs/USAGE.tr.md`: yedi adım adım iş akışı, rol-model tablosu, Sheepdog'a kısa cümleler.
- `SHEEPDOG_DRY=1`: `launch.sh` oturum açmadan çalıştıracağı komutu gösterir.
- Duman testi 169 kontrole çıktı.

## v0.2: Linux, macOS ve Windows

- Betikler macOS (kendi bash 3.2 sürümü dahil) ve Windows Git Bash'te çalışır; GitHub otomatik kontrolü üç sistemde koşar.
- `trust.py`: güven onayı kontrolü tek yerde; yollar her sistemde normalleştirilir. Git deposunda klasörün kendisi ya da git kökü onaylı olmalı.
- `doctor.sh`: `python3` ya da `python`, git 2.38 ve Claude Code sürüm kontrolü `sort -V` olmadan.
- `board.sh`: özet satırı, tıkanan kart uyarısı, `--watch` ile canlı tablo.
- Satır sonları `.gitattributes` ile LF'e sabitlendi (Windows'ta betikler bozulmaz).
- Duman testi 58 kontrole çıktı: sahte `claude` ile sürüm kontrolü ve güven kontrolü dahil.

## v0.1: deneysel ilk sürüm

Claude Code 2.1.293 ile Linux'ta denendi. Parçalar:

- Ajanlar: Sheepdog (`.claude/agents/sheepdog.md`); işçi, incelemeci, doğrulayıcı ve birleştirici rolleri (`roles/`).
- İş kartı yazdıran yetenek: `/is-karti` (`.claude/skills/is-karti/`).
- Programlar (model harcamaz): `board.sh` (kart durumları), `watchdog.sh` (oturum gözcüsü), `dry-run.sh`.
- Yardımcılar: `launch.sh` (arka plan oturumu açar), `state.sh` (kart durumunu değiştirir).
- Örnek kartlar: `examples/tr/`.
- `jobs/` klasörü (kartların yeri; içeriği git'e girmez).
