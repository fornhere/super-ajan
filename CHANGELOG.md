# Değişiklik günlüğü

## v0.2: Linux, macOS ve Windows

- Betikler macOS (kendi bash 3.2 sürümü dahil) ve Windows Git Bash'te çalışır; GitHub otomatik kontrolü üç sistemde koşar.
- `guven.py`: güven onayı kontrolü tek yerde; yollar her sistemde normalleştirilir. Git deposunda klasörün kendisi ya da git kökü onaylı olmalı.
- `kontrol.sh`: `python3` ya da `python`, git 2.38 ve Claude Code sürüm kontrolü `sort -V` olmadan.
- `pano.sh`: özet satırı, tıkanan kart uyarısı, `--izle` ile canlı tablo.
- Satır sonları `.gitattributes` ile LF'e sabitlendi (Windows'ta betikler bozulmaz).
- Duman testi 58 kontrole çıktı: sahte `claude` ile sürüm kontrolü ve güven kontrolü dahil.

## v0.1: deneysel ilk sürüm

Claude Code 2.1.293 ile Linux'ta denendi. Parçalar:

- Ajanlar: süper ajan (`.claude/agents/super-ajan.md`); işçi, incelemeci, doğrulayıcı ve birleştirici rolleri (`roller/`).
- İş kartı yazdıran yetenek: `/is-karti` (`.claude/skills/is-karti/`).
- Programlar (model harcamaz): `pano.sh` (kart durumları), `gozcu.sh` (oturum gözcüsü), `birlestirme-hazirla.sh`.
- Yardımcılar: `baslat.sh` (arka plan oturumu açar), `durum.sh` (kart durumunu değiştirir).
- Örnek kartlar: `ornek-kartlar/`.
- `isler/` klasörü (kartların yeri; içeriği git'e girmez).
