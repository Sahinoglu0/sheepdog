---
name: is-karti
description: Bir isteği, işçi ajanın soru sormadan yapabileceği iş kartlarına çevirir. İş kartı yaz, işi böl, bu işi hazırla dendiğinde kullan.
---

# İş kartı yazma

İsteği iş kartlarına çevir. İşçi sonradan soru soramayacak, o yüzden belirsizliği şimdi kapat.

## Adımlar

1. İsteği parçalara böl. Bir kart, tek başına bitirilip kontrol edilebilen en küçük iştir.
2. Gereken dosyalara ve mevcut işe kısaca bak.
3. Kullanıcıya her seferinde tek soru sor. Şıklar varsa önerini başa yaz. İşçinin kafasına göre karar vereceği bir şey kalmayınca dur. Kullanıcı cevap vermezse varsayım yapma, soruyu bekleyen olarak karta yaz.
4. Her kartı `isler/001-kisa-ad/kart.md` olarak kaydet. Numaralar sırayla gitsin.
5. Hepsini `Durum: taslak` bırak. Kullanıcı onaylayınca `Durum: hazir` yap. `Tür` satırı `kod` veya `icerik` olur. Başka kartı bekliyorsa `Bekliyor:` satırına kart klasörünün adını yaz (birden çoksa virgülle ayır).

## Kart şablonu

```markdown
# 001: Kısa başlık

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /işin/yapılacağı/klasör

## Ne yapılacak
Tek paragraf. Okuyan biri soru sormadan yapabilsin.

## Neye dokunma
Kapsam dışı olanlar.

## Bitti demek
- [ ] Ne olmuş olacak, neyle kanıtlanacak.
- [ ] Ne olmuş olacak, neyle kanıtlanacak.

## Takılırsan
Nerede durup haber verecek.
```

"Bitti demek" maddeleri işi yapmayan birinin bakıp evet ya da hayır diyebileceği kadar net olsun. "Rapor iyi olsun" olmaz. "Her iddianın yanında kaynak linki var" olur.
