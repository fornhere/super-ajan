#!/bin/bash
# Duman testi, model harcamaz, gerçek claude oturumu açmaz.
# Depoyu geçici klasöre kopyalar, sahte kartlarla betikleri sınar. kullanım: bash testler/duman.sh
KOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
OK=0; HATA=0
gecti(){ OK=$((OK+1)); echo "  ok   $1"; }
kaldi(){ HATA=$((HATA+1)); echo "  HATA $1"; [ -z "$2" ] || printf '%s\n' "$2" | sed 's/^/       | /'; }
# kod beklenen ad komut...: çıkış kodu beklenene eşit mi; çıktı SON'da kalır
kod(){ local b="$1" ad="$2"; shift 2; local o c; o="$("$@" 2>&1)"; c=$?
  if [ "$c" = "$b" ]; then gecti "$ad"; else kaldi "$ad (çıkış $c, beklenen $b)" "$o"; fi; SON="$o"; }
icerir(){ if printf '%s\n' "$SON" | grep -qF -- "$2"; then gecti "$1"; else kaldi "$1 (çıktıda yok: $2)" "$SON"; fi; }
icermez(){ if printf '%s\n' "$SON" | grep -qF -- "$2"; then kaldi "$1 (çıktıda olmamalı: $2)" "$SON"; else gecti "$1"; fi; }

tar -C "$KOK" --exclude=./.git --exclude=./.claude -cf - . | tar -C "$T" -xf -
cd "$T" || exit 1
mkdir -p isler

echo "bash -n"
for f in ./*.sh testler/*.sh; do kod 0 "bash -n $f" bash -n "$f"; done

echo "sahte kartlar"
kart(){ mkdir -p "isler/$1"; printf '# %s\n\nDurum: %s\nTür: kod\nBekliyor: %s\nProje: %s\n' "$1" "$2" "$3" "$T" > "isler/$1/kart.md"; }
kart 001-a bitti yok
kart 002-b hazir 001-a        # beklediği bitti: başlayabilir
kart 003-c hazir 004-d        # beklediği hazir: başlayamaz
kart 004-d hazir yok          # beklemiyor: başlayabilir
kart 005-e taslak yok         # hazir değil: başlayamaz
kart 006-f hazir 099-yok      # beklediği kart yok: başlayamaz

echo "durum.sh"
kod 0 "geçerli durum kabul" ./durum.sh isler/005-e calisiyor
icerir "çıktı kart: durum" "005-e: calisiyor"
if grep -qx 'Durum: calisiyor' isler/005-e/kart.md; then gecti "Durum satırı yazıldı"; else kaldi "Durum satırı yazılmadı" "$(cat isler/005-e/kart.md)"; fi
if grep -q ' 005-e calisiyor$' .gecmis 2>/dev/null; then gecti ".gecmis kaydı"; else kaldi ".gecmis kaydı yok"; fi
kod 0 "bütün geçerli durumlar" bash -c 'for d in taslak hazir calisiyor inceleme dogrulama birlesme-bekliyor birlesiyor bitti tikandi; do ./durum.sh isler/005-e "$d" >/dev/null || exit 1; done'
./durum.sh isler/005-e taslak >/dev/null
kod 1 "geçersiz durum reddedilir" ./durum.sh isler/005-e uydurma
icerir "geçersiz durum mesajı" "Geçersiz durum"
if grep -qx 'Durum: taslak' isler/005-e/kart.md; then gecti "geçersiz durum kartı bozmadı"; else kaldi "geçersiz durum kartı değiştirdi" "$(cat isler/005-e/kart.md)"; fi
kod 1 "olmayan kart reddedilir" ./durum.sh isler/yok-kart hazir

echo "pano.sh"
kod 0 "tablo" ./pano.sh
icerir "başlık" "KART"
for k in 001-a 002-b 003-c 004-d 005-e 006-f; do icerir "tabloda $k" "$k"; done
kod 0 "--baslayabilir" ./pano.sh --baslayabilir
B="$SON"
for k in 002-b 004-d; do icerir "başlayabilir: $k" "$k"; done
for k in 001-a 003-c 005-e 006-f; do icermez "başlayamaz: $k" "$k"; done
if [ "$(printf '%s\n' "$B" | grep -c .)" = 2 ]; then gecti "tam iki kart"; else kaldi "kart sayısı 2 değil" "$B"; fi

echo "baslat.sh (claude açılmaz)"
kod 1 "olmayan kart" ./baslat.sh isler/yok-kart isci
icerir "Kart yok mesajı" "Kart yok"
kod 1 "olmayan rol" ./baslat.sh isler/004-d uydurma-rol
icerir "Rol yok mesajı" "Rol yok"

echo "birlestirme-hazirla.sh"
R="$T/depo"; mkdir "$R"
export GIT_AUTHOR_NAME=duman GIT_AUTHOR_EMAIL=duman@example.invalid GIT_COMMITTER_NAME=duman GIT_COMMITTER_EMAIL=duman@example.invalid
g(){ git -C "$R" -c commit.gpgsign=false "$@"; }
if g init -q -b main && echo bir > "$R/a.txt" && echo x > "$R/b.txt" && g add . && g commit -qm ilk \
  && g checkout -q -b temiz && echo iki > "$R/yeni.txt" && g add . && g commit -qm temiz \
  && g checkout -q main && g checkout -q -b cakisan && echo dal > "$R/a.txt" && g commit -qam cakisan \
  && g checkout -q main && echo ana > "$R/a.txt" && g commit -qam ana; then
  kod 0 "temiz birleşme" ./birlestirme-hazirla.sh "$R" temiz main
  icerir "TEMIZ der" "TEMIZ"
  kod 1 "çakışma" ./birlestirme-hazirla.sh "$R" cakisan main
  icerir "CAKISMA der" "CAKISMA"
  icerir "çakışan dosya" "a.txt"
  kod 2 "olmayan dal" ./birlestirme-hazirla.sh "$R" yok-dal main
  if [ "$(g rev-parse main)" = "$(g rev-parse HEAD)" ] && [ -z "$(g status --porcelain)" ]; then gecti "ana dal değişmedi"; else kaldi "ana dal/çalışma ağacı değişti"; fi
else
  kaldi "geçici git deposu kurulamadı (git sürümü: $(git --version))"
fi

echo
echo "sonuç: $OK geçti, $HATA hata"
[ "$HATA" = 0 ]
