# Güvenlik politikası

[English](SECURITY.md) · **Türkçe**

Sheepdog, otomatik izin modunda özerk kodlama oturumları başlatır. Önemli bir şeyde kullanmadan önce [README.tr.md](README.tr.md) içindeki **Güvenlik ve sınırlar** bölümünü okuyun.

## Bilinen sınırlar (tasarım gereği)

- Rol kısıtları (push yok, durum düzenleme yok, `.env` okuma yok) istem kurallarıdır, kilit değildir.
- Yöneticide Bash vardır. "Dosya yazma aracı yok" bir davranış kuralıdır, güvenlik kutusu değildir.
- `--add-dir` bir oturuma erişim ekler, kısıtlamaz. Bir işçi kart klasörü dışına, merkez dahil, yazabilir.
- İncelemenin bağımsızlığı bir istem kuralıdır: kart klasörü bütün rollerce yazılabilir.
- Oturumlar web'den ya da depolardan okudukları metinden etkilenebilir.

Önemli işleri ayrı bir işletim sistemi hesabında ya da kapsayıcıda çalıştırın.

## Güvenlik açığı bildirme

Lütfen bu depoda GitHub'ın özel güvenlik açığı bildirimini (**Security → Report a vulnerability**) kullanın. Sömürülebilir sorunlar için herkese açık sorun açmayın. Sürümü (`CHANGELOG.tr.md`), işletim sisteminizi ve en küçük yeniden üretimi ekleyin. Bildirimleri bir hafta içinde yanıtlamayı hedefliyoruz.
