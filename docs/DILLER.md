# Diller

[English](LANGUAGES.md) · **Türkçe**

Kullanıcıya dönük her şey İngilizce ve Türkçe vardır: betik mesajları, rol istemleri, yönetici ajan, kart yetenekleri, belgeler, deneme projesi ve örnek kartlar.

## Dil seçimi

| Ne | İngilizce (varsayılan) | Türkçe |
|---|---|---|
| Kalıcı geçiş | `./sheepdog lang en` | `./sheepdog lang tr` |
| Yalnız tek komut | `SHEEPDOG_LANG=en ./board.sh` | `SHEEPDOG_LANG=tr ./board.sh` |
| Yönetici ajan | `claude --agent sheepdog …` | `claude --agent sheepdog-tr …` |
| Kart yeteneği | `/job-card` | `/is-karti` |
| Rol istemleri | `roles/en/` | `roles/tr/` |
| Deneme seti | `bash trial/setup.sh <klasör>` | `bash trial/setup.sh <klasör> --lang tr` |
| Örnek kartlar | `examples/en/` | `examples/tr/` |

Dil şu sırayla çözülür: `SHEEPDOG_LANG`, sonra `.lang` dosyası, sonra İngilizce.

## Dilleri karıştırmak

Kartlar, durumlar ve roller **iki dilde de** kabul edilir; aynı merkezde karışık da olabilir. Kart yazıldığı dili korur: `state.sh` İngilizce kartta `Status: working`, Türkçe kartta Türkçe değeri yazar. Kayıt (`.history`) ve bütün iç işleyiş İngilizce adları kullanır.

| Kart alanı (Türkçe) | İngilizce karşılığı |
|---|---|
| `Durum:` | `Status:` |
| `Tür:` | `Type:` |
| `Bekliyor:` | `Waits-for:` |
| `Proje:` | `Project:` |
| `Model:` | `Model:` |
| `Efor:` | `Effort:` |

| Tür | İngilizce karşılığı |
|---|---|
| `kod` | `code` |
| `icerik` | `content` |

| Durum | İngilizce karşılığı |
|---|---|
| `taslak` | `draft` |
| `hazir` | `ready` |
| `calisiyor` | `working` |
| `inceleme` | `review` |
| `dogrulama` | `verify` |
| `birlesme-bekliyor` | `merge-queue` |
| `birlesiyor` | `merging` |
| `bitti` | `done` |
| `tikandi` | `stuck` |

| Rol | İngilizce karşılığı |
|---|---|
| `isci` | `worker` |
| `reviewer` | `reviewer` |
| `dogrulayici` | `verifier` |
| `birlestirici` | `merger` |

Karar dosyaları `SONUÇ: GEÇTİ` / `SONUÇ: KALDI` ile (İngilizce: `RESULT: PASSED` / `RESULT: FAILED`) biter; birleştirme provası `TEMIZ` / `CAKISMA` yazar (İngilizce: `CLEAN` / `CONFLICT`). Yönetici ikisini de anlar.

## Başka dil eklemek

1. `roles/en/` klasörünü `roles/<kod>/` olarak kopyalayıp dört istemi çevirin.
2. `lang.sh` (`T` yardımcısı şimdilik iki dil alır) ve `trial/setup.py` dosyalarına dili öğretin.
3. `.claude/agents/sheepdog.md` ve `.claude/skills/job-card/` dosyalarını çevrilmiş metinle kopyalayın.
4. Belgeleri çevirin ve bir duman testi kontrolü ekleyin.
