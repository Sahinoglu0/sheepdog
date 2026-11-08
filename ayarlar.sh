#!/bin/bash
# Süper ajan kitinin model ayarları. baslat.sh her yeni oturumda bu dosyayı okur.
#
# Rol          | İş                                     | Model kullanır mı
# Süper ajan   | Oturumları yönetir, kararı size sorar  | evet, ama ayarı burada değil: .claude/agents/super-ajan.md (model:, effort:)
# İşçi         | Kartı yapar, sonuç ve kanıt yazar      | evet
# İncelemeci   | İşi yapmadan, istenen yapıldı mı bakar | evet
# Doğrulayıcı  | Kartın kontrollerini çalıştırır        | evet
# Birleştirici | Testleri koşup ana dala alır           | evet
# Gözcü, pano, birleştirme provası                      | HAYIR, model ve limit harcamaz
#
# Model takma adları: opus, sonnet, haiku. Efor: low, medium, high.
# Profiller öneridir; maliyet ve başarı bakımından ölçülmedi.
# Değişiklik yalnız yeni başlayan oturumlara uygulanır.

# 1) Profil seçin: ekonomik | dengeli | guclu
PROFIL=dengeli

case "$PROFIL" in
  ekonomik)  # kapsamı dar, bitti şartı net işler
    MODEL_ISCI=sonnet;  EFOR_ISCI=medium
    MODEL_INCELEMECI=sonnet; EFOR_INCELEMECI=medium
    MODEL_DOGRULAYICI=haiku; EFOR_DOGRULAYICI=medium
    MODEL_BIRLESTIRICI=sonnet; EFOR_BIRLESTIRICI=medium ;;
  guclu)     # karmaşık kod, zor inceleme
    MODEL_ISCI=opus;    EFOR_ISCI=high
    MODEL_INCELEMECI=opus; EFOR_INCELEMECI=high
    MODEL_DOGRULAYICI=sonnet; EFOR_DOGRULAYICI=high
    MODEL_BIRLESTIRICI=opus; EFOR_BIRLESTIRICI=high ;;
  *)         # dengeli (varsayılan)
    MODEL_ISCI=sonnet;  EFOR_ISCI=high
    MODEL_INCELEMECI=sonnet; EFOR_INCELEMECI=high
    MODEL_DOGRULAYICI=sonnet; EFOR_DOGRULAYICI=medium
    MODEL_BIRLESTIRICI=sonnet; EFOR_BIRLESTIRICI=high ;;
esac

# 2) İsterseniz tek bir rolü profilden bağımsız değiştirin (başındaki # işaretini kaldırın):
# MODEL_ISCI=opus
# EFOR_DOGRULAYICI=low

# 3) Tek bir işin işçisi için karta şu satırları ekleyebilirsiniz (diğer roller etkilenmez):
#    Model: opus
#    Efor: high
