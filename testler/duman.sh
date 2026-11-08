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
kart 007-g tikandi yok         # tıkanan kart panoda uyarı verir

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
for k in 001-a 002-b 003-c 004-d 005-e 006-f 007-g; do icerir "tabloda $k" "$k"; done
icerir "özet satırı" "özet:"
icerir "özette hazir sayısı" "4 hazir"
icerir "tıkanan kart uyarısı" "dikkat: 007-g"
kod 0 "--baslayabilir" ./pano.sh --baslayabilir
B="$SON"
for k in 002-b 004-d; do icerir "başlayabilir: $k" "$k"; done
for k in 001-a 003-c 005-e 006-f 007-g; do icermez "başlayamaz: $k" "$k"; done
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

echo "kontrol.sh (sahte claude ile)"
mkdir -p "$T/sahte-bin"
cat > "$T/sahte-bin/claude" <<'SAHTE'
#!/bin/bash
case "$1" in
  --version) echo "${SAHTE_SURUM:-2.1.293} (Claude Code)";;
  --help) printf -- '  --bg  arka planda başlat\n  --permission-mode <mode>  izin modu\n    (choices: "default", "auto")\n';;
  agents) echo "Usage: claude agents [options]";;
esac
SAHTE
chmod +x "$T/sahte-bin/claude"
kod 0 "yeterli sürüm" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.2.0 ./kontrol.sh
icerir "sürüm kabul" "claude sürümü 2.2.0"
icerir "--bg görülür" "claude --bg destekleniyor"
kod 1 "eski sürüm reddedilir" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.1.200 ./kontrol.sh
icerir "eski sürüm mesajı" "en az 2.1.293"
kod 0 "eşit sürüm kabul" env PATH="$T/sahte-bin:$PATH" SAHTE_SURUM=2.1.293 ./kontrol.sh

echo "guven.py"
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
G="$T/guven"; mkdir -p "$G/onayli-depo" "$G/onaysiz-depo" "$G/ust/alt" "$T/baska"
git -C "$G/onayli-depo" init -q; git -C "$G/onaysiz-depo" init -q
"$PY" - "$G" "$G/onayli-depo" > "$T/claude.json" <<'JS'
import json,os,sys
print(json.dumps({"projects":{os.path.realpath(a).replace(os.sep,"/"):{"hasTrustDialogAccepted":True} for a in sys.argv[1:]}}))
JS
export SUPER_AJAN_CLAUDE_JSON="$T/claude.json"
kod 0 "onaylı git deposu" "$PY" guven.py "$G/onayli-depo"
kod 1 "üstü onaylı ama kendisi onaysız git deposu" "$PY" guven.py "$G/onaysiz-depo"
kod 0 "git dışı klasör üstten onay alır" "$PY" guven.py "$G/ust/alt"
kod 1 "hiçbir üstü onaylı olmayan klasör" "$PY" guven.py "$T/baska"
unset SUPER_AJAN_CLAUDE_JSON

echo
echo "sonuç: $OK geçti, $HATA hata"
[ "$HATA" = 0 ]
