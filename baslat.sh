#!/bin/bash
# kullanım: ./baslat.sh isler/001-is [isci|reviewer|dogrulayici|birlestirici]
set -e
MERKEZ="$(cd "$(dirname "$0")" && pwd)"; K="${1%/}"; ROL="${2:-isci}"
KART="$MERKEZ/$K/kart.md"; AD="$(basename "$K")"
[ -f "$KART" ] || { echo "Kart yok: $KART"; exit 1; }
[ -f "$MERKEZ/roller/$ROL.md" ] || { echo "Rol yok: $ROL"; exit 1; }
PROJE="$(sed -n 's/^Proje: //p' "$KART" | head -1)"
[ -d "$PROJE" ] || { echo "Proje klasörü yok: $PROJE"; exit 1; }
PY=python3; "$PY" -c "" 2>/dev/null || PY=python
"$PY" "$MERKEZ/guven.py" "$PROJE" || { echo "Güven onayı yok: $PROJE içinde bir kez claude açıp onay verin"; exit 2; }
case "$ROL" in isci) AD2="$AD"; MODEL=sonnet; EF=high;; reviewer) AD2="$AD-reviewer"; MODEL=sonnet; EF=high;; dogrulayici) AD2="$AD-dogrulayici"; MODEL=sonnet; EF=medium;; birlestirici) AD2="$AD-birlestirici"; MODEL=sonnet; EF=high;; esac
cd "$PROJE"
claude --bg ${SUPER_AJAN_BAYRAK:-} --permission-mode auto --model "$MODEL" --effort "$EF" --append-system-prompt-file "$MERKEZ/roller/$ROL.md" --add-dir "$MERKEZ" --name "$AD2" -- "Kartın: $KART. Rolüne göre işini yap ve kartın klasörüne yaz."
[ "$ROL" = isci ] && "$MERKEZ/durum.sh" "$K" calisiyor >/dev/null
echo "başladı: $AD2 ($PROJE)"
