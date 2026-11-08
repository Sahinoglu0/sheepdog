# 901: Erken iadede negatif gecikme

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: {{PROJE}}

## Ne yapılacak
Proje kökünde `python3 -m kitaplik gecikme --son-tarih 2026-01-15 --iade-tarihi 2026-01-01` komutuyla hatayı iki kez üret: başlangıç çıktısı `Gecikme: -14 gün`, beklenen `Gecikme: 0 gün`. İade akışının da kullandığı gecikme hesabının kök nedenini bul ve düzelt. Erken veya ödünçle aynı gün yapılan iadede gecikme sıfır, son teslim gününde sıfır, sonrasında gerçek pozitif gün sayısı olmalı. Ödünç tarihinden önce iade reddedilmeye devam etsin. Önce yeni regresyon testini ekleyip mevcut kodda kırıldığını göster; sonra düzeltip geçtiğini kanıtla. Python 3 yalnız `python` adıyla kuruluysa komutlarda onu kullan.

## Neye dokunma
Yalnız `kitaplik/islemler.py` ve yeni `testler/test_iade_regresyon.py` dosyasında çalış. Mevcut testleri gevşetme. Listeleme özelliğini, CLI biçimini veya veri şemasını değiştirme. Push, PR ve ana dala birleştirme yok.

## Bitti demek
- [ ] Yeniden üretme komutu düzeltmeden önce iki kez `Gecikme: -14 gün`, sonra `Gecikme: 0 gün` veriyor; komutlar, çıkış kodları ve çıktılar kartın `sonuc.md` dosyasında.
- [ ] `python3 -m unittest testler.test_iade_regresyon` düzeltmeden önce kırılıyor, düzeltmeyle geçiyor; her iki çalışmanın çıktısı `sonuc.md` içinde. Testler gerçek `iade_al` akışında aynı gün/erken/son gün/geç iade ve ödünçten önce iadenin reddini kapsıyor.
- [ ] `python3 -m unittest` bütün testlerle geçiyor; komut ve çıktı `sonuc.md` içinde.
- [ ] Dal, commit ve worktree yolu `sonuc.md` içinde; diff yalnız izin verilen iki dosyayı değiştiriyor.

## Takılırsan
Hatayı üretemezsen, kapsam dışında değişiklik gerekirse veya iş 30 dakikayı geçecekse durup somut engeli süper ajana bildir.
