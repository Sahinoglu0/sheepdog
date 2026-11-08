# Katkı rehberi

[English](CONTRIBUTING.md) · **Türkçe**

Yardımınız için teşekkürler. Sheepdog bilerek küçük tutuldu; lütfen öyle kalsın.

## Temel kurallar

- **Betikler model harcamaz.** Mekanik olarak karar verilebilen şeyi istemle değil, betikle yapın.
- **Platformlar arası bash.** Linux, macOS (kendi bash 3.2 sürümü) ve Windows Git Bash. `sort -V` yok, ilişkisel dizi yok, yalnız GNU'ya özgü bayrak yok.
- **İstemleri kısa tutun.** Rol dosyaları her oturum başında okunur.
- **Davranış kuralı güvenlik değildir.** Bir istem kuralını garanti gibi anlatmayın.
- **İki dil.** Kullanıcıya dönük metin İngilizce ve Türkçe vardır. İkisini de ekleyin ya da hangi yarının eksik olduğunu sorunda belirtin.

## Çekme isteği açmadan önce

```bash
bash tests/smoke.sh      # şununla bitmeli: N geçti, 0 hata
python3 tools/build_assets.py   # yalnız görselleri değiştirdiyseniz
```

Duman testi depoyu geçici klasöre kopyalar, sahte kartlar ve sahte `claude` kullanır, gerçek oturum açmaz. Eklediğiniz ya da düzelttiğiniz her davranış için bir kontrol ekleyin.

## Üslup

- Yeni kullanıcı komutları `./sheepdog` üzerinden İngilizce adlarla gelir.
- Çekme isteği başına tek mantıksal değişiklik. [CHANGELOG.tr.md](CHANGELOG.tr.md) (ve CHANGELOG.md) güncellenir.
- Görseller `tools/build_assets.py` içindedir; SVG'leri değil üreticiyi düzenleyin.

## Hatalar

`./sheepdog doctor` çıktısıyla ve gerekiyorsa `./sheepdog board` ile `./sheepdog timeline` çıktısıyla bir sorun açın. Sır ya da özel kart içeriği yapıştırmayın.
