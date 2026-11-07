#!/bin/bash
# Kart durum tablosu, model harcamaz. --baslayabilir: başlatılabilir kartları listeler.
cd "$(dirname "$0")"
alan(){ sed -n "s/^$1: //p" "$2" | head -1; }
if [ "$1" = "--baslayabilir" ]; then
  for k in isler/*/kart.md; do [ -f "$k" ] || continue
    [ "$(alan Durum "$k")" = hazir ] || continue
    b="$(alan Bekliyor "$k")"; [ -z "$b" ] && b=yok
    if [ "$b" = yok ] || [ "$(alan Durum "isler/$b/kart.md" 2>/dev/null)" = bitti ]; then basename "$(dirname "$k")"; fi
  done; exit 0
fi
printf '%-26s %-19s %-8s %-24s %s\n' KART DURUM TUR BEKLIYOR PROJE
for k in isler/*/kart.md; do [ -f "$k" ] || continue
  printf '%-26s %-19s %-8s %-24s %s\n' "$(basename "$(dirname "$k")")" "$(alan Durum "$k")" "$(alan Tür "$k")" "$(alan Bekliyor "$k")" "$(alan Proje "$k" | sed "s#$HOME#~#")"
done
