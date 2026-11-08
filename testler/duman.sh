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

echo "deneme/kur.sh"
kod 0 "deneme kurucusu bash sözdizimi" bash -n deneme/kur.sh
# Önce dolu hedef: henüz kartlar yok, red nedeni kart çakışması olamaz.
DOLU="$T/dolu hedef"; mkdir "$DOLU"
printf 'korunacak\n' > "$DOLU/.gizli"
kod 1 "dolu hedef reddedilir" bash deneme/kur.sh "$DOLU"
icerir "dolu hedef açıklaması" "Hedef boş bir klasör olmalı"
if [ "$(cat "$DOLU/.gizli")" = korunacak ] && [ "$(ls -A "$DOLU" | wc -l | tr -d ' ')" = 1 ] \
  && [ ! -e isler/901-iade-hatasi ] && [ ! -e isler/902-gecikme-listesi ] && [ ! -e isler/903-kullanim-notu ]; then
  gecti "dolu hedef ve kartlar değişmedi"
else kaldi "dolu hedef reddinde dosyalar değişti"; fi

# Ayrı global config, kullanıcının ayarını okumadan/yazmadan kimlik yedeğini sınar.
DENEME_GIT_CONFIG="$T/deneme-global-config"
printf '[init]\n\tdefaultBranch = baska\n' > "$DENEME_GIT_CONFIG"
cp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
D="$T/kitaplık denemesi"
kod 0 "geçici hedefe kurulum" env GIT_CONFIG_GLOBAL="$DENEME_GIT_CONFIG" GIT_CONFIG_NOSYSTEM=1 bash deneme/kur.sh "$D"
icerir "kurulum sonraki adımları gösterir" "claude --agent super-ajan --name super-ajan --permission-mode auto"
icerir "güven onayı adımı" "güven onayını"
icerir "başlatma isteği" "hazır kartları başlat"
icerir "canlı pano komutu" "./pano.sh --izle"
kod 0 "hedefte git deposu" git -C "$D" rev-parse --is-inside-work-tree
icerir "git deposu doğrulaması" "true"
kod 0 "hedefte ilk commit" git -C "$D" rev-parse --verify HEAD
DENEME_ILK="$SON"
kod 0 "hedef main dalında" git -C "$D" branch --show-current
icerir "ana dal adı" "main"
kod 0 "yalnız yerel kimlik adı" git -C "$D" config --local --get user.name
icerir "yedek ad" "deneme"
kod 0 "yalnız yerel kimlik e-postası" git -C "$D" config --local --get user.email
icerir "yedek e-posta" "deneme@example.invalid"
kod 0 "global ayar aynı kaldı" cmp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
kod 0 "projenin başlangıç testleri" bash -c 'cd "$1" && PYTHONUTF8=1 "$2" -m unittest' _ "$D" "$PY"
icerir "başlangıçta 8 test" "Ran 8 tests"
icerir "başlangıç test sonucu" "OK"
kod 0 "erken iade hatasını yeniden üret" bash -c 'cd "$1" && PYTHONUTF8=1 "$2" -m kitaplik gecikme --son-tarih 2026-01-15 --iade-tarihi 2026-01-01' _ "$D" "$PY"
icerir "bilerek bırakılan negatif gecikme" "Gecikme: -14 gün"
DENEME_MUTLAK="$("$PY" -c 'import pathlib,sys; print(pathlib.Path(sys.argv[1]).resolve().as_posix())' "$D")"
for ad in 901-iade-hatasi 902-gecikme-listesi 903-kullanim-notu; do
  if [ -f "isler/$ad/kart.md" ] && grep -qx 'Durum: hazir' "isler/$ad/kart.md" \
    && grep -qxF "Proje: $DENEME_MUTLAK" "isler/$ad/kart.md"; then
    gecti "hazır kart ve mutlak proje yolu: $ad"
  else kaldi "kart veya proje yolu yanlış: $ad"; fi
done
if grep -F '{{PROJE}}' isler/90*/kart.md; then kaldi "kartlarda yer tutucu kaldı"; else gecti "kartlarda yer tutucu yok"; fi
kod 0 "deneme kartları başlatılabilirlik" ./pano.sh --baslayabilir
icerir "901 başlayabilir" "901-iade-hatasi"
icerir "902 başlayabilir" "902-gecikme-listesi"
icermez "903 bağımlı, başlayamaz" "903-kullanim-notu"
cp isler/901-iade-hatasi/kart.md "$T/deneme-kart-once"
kod 1 "aynı hedefe ikinci kurulum reddedilir" bash deneme/kur.sh "$D"
kod 1 "aynı adlı kart yeni hedefi engeller" bash deneme/kur.sh "$T/kurulmamali"
icerir "kart çakışması açıklaması" "Kart zaten var"
if [ ! -e "$T/kurulmamali" ]; then gecti "kart çakışmasında hedef oluşturulmadı"; else kaldi "çakışmada hedefe yazıldı"; fi
kod 0 "mevcut kartın üzerine yazılmadı" cmp isler/901-iade-hatasi/kart.md "$T/deneme-kart-once"
if [ "$(git -C "$D" rev-parse HEAD)" = "$DENEME_ILK" ] && [ -z "$(git -C "$D" status --porcelain)" ]; then
  gecti "tekrar kurulum projeyi değiştirmedi"
else kaldi "tekrar kurulum projeyi değiştirdi"; fi

# Boş ama önceden var olan hedef ve mevcut global kimlik de desteklenir.
E="$T/ikinci-merkez"; mkdir "$E" "$T/bos-hedef"
cp -R deneme "$E/deneme"
git config --file "$DENEME_GIT_CONFIG" user.name "Ornek Kullanici"
git config --file "$DENEME_GIT_CONFIG" user.email "ornek@example.invalid"
cp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"
kod 0 "mevcut boş hedefe kurulum" env GIT_CONFIG_GLOBAL="$DENEME_GIT_CONFIG" GIT_CONFIG_NOSYSTEM=1 bash "$E/deneme/kur.sh" "$T/bos-hedef"
kod 1 "global kimlik varsa yerel ad yazılmaz" git -C "$T/bos-hedef" config --local --get user.name
kod 1 "global kimlik varsa yerel e-posta yazılmaz" git -C "$T/bos-hedef" config --local --get user.email
kod 0 "mevcut global kimlik değişmedi" cmp "$DENEME_GIT_CONFIG" "$T/deneme-global-once"

echo
echo "sonuç: $OK geçti, $HATA hata"
[ "$HATA" = 0 ]
