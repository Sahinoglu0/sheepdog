"""İş kuralları. Tarihler ISO biçimindedir: YYYY-AA-GG."""

from datetime import date, timedelta


def gecikme_gunu(son_tarih, iade_tarihi):
    return (date.fromisoformat(iade_tarihi) - date.fromisoformat(son_tarih)).days


def kitap_ekle(veri, kod, ad):
    if not kod.strip() or not ad.strip():
        raise ValueError("Kitap kodu ve adı boş olamaz")
    if kod in veri["kitaplar"]:
        raise ValueError("Kitap kodu zaten var")
    veri["kitaplar"][kod] = ad


def odunc_ver(veri, kod, uye, tarih):
    baslangic = date.fromisoformat(tarih)
    if kod not in veri["kitaplar"]:
        raise ValueError("Kitap bulunamadı")
    if not uye.strip():
        raise ValueError("Üye adı boş olamaz")
    if any(o["kitap"] == kod and o["iade"] is None for o in veri["oduncler"]):
        raise ValueError("Kitap zaten ödünçte")
    kayit = {
        "no": len(veri["oduncler"]) + 1,
        "kitap": kod,
        "uye": uye,
        "tarih": tarih,
        "son_tarih": (baslangic + timedelta(days=14)).isoformat(),
        "iade": None,
    }
    veri["oduncler"].append(kayit)
    return kayit["no"]


def iade_al(veri, no, tarih):
    iade = date.fromisoformat(tarih)
    for kayit in veri["oduncler"]:
        if kayit["no"] != no:
            continue
        if kayit["iade"] is not None:
            raise ValueError("Ödünç zaten iade edildi")
        if iade < date.fromisoformat(kayit["tarih"]):
            raise ValueError("İade ödünç tarihinden önce olamaz")
        gun = gecikme_gunu(kayit["son_tarih"], tarih)
        kayit["iade"] = tarih
        return gun
    raise ValueError("Ödünç bulunamadı")
