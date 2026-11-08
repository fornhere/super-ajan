# Değişiklik günlüğü

## v0.1: deneysel ilk sürüm

Claude Code 2.1.293 ile Linux'ta denendi. Parçalar:

- Ajanlar: süper ajan (`.claude/agents/super-ajan.md`); işçi, incelemeci, doğrulayıcı ve birleştirici rolleri (`roller/`).
- İş kartı yazdıran yetenek: `/is-karti` (`.claude/skills/is-karti/`).
- Programlar (model harcamaz): `pano.sh` (kart durumları), `gozcu.sh` (oturum gözcüsü), `birlestirme-hazirla.sh`.
- Yardımcılar: `baslat.sh` (arka plan oturumu açar), `durum.sh` (kart durumunu değiştirir).
- Örnek kartlar: `ornek-kartlar/`.
- `isler/` klasörü (kartların yeri; içeriği git'e girmez).
