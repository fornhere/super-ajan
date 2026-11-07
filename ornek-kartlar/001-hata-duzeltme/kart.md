# 001: Boş e-postada kayıt formu çöküyor

Durum: taslak
Tür: kod
Bekliyor: yok
Proje: /projenizin/klasörü

## Ne yapılacak
Kayıt formunda e-posta alanı boş bırakılınca uygulama hata verip kapanıyor. Hatayı önce yeniden üret, kökünü bul ve düzelt. Boş e-postada kullanıcıya anlaşılır bir uyarı gösterilsin.

## Neye dokunma
Kayıt formu dışındaki dosyalar. Veritabanı şeması. Push, PR ve ana dala birleştirme yok.

## Takılırsan
Hatayı üretemezsen veya iş 30 dakikayı geçecekse dur, nedenini süper ajana bildir. Tasarım kararı gerekiyorsa seçenekleri sor.

## Bitti demek
- [ ] Hatayı düzeltmeden kıran, düzeltmeyle geçen bir test var; komut ve çıktı sonuc.md içinde.
- [ ] Mevcut kayıt testleri hâlâ geçiyor.
- [ ] Dal adı ve commit hash'i sonuc.md içinde.
