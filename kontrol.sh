#!/bin/bash
# kullanım: ./kontrol.sh [proje-klasörü ...]
# Makineyi yoklar, hiçbir şeyi değiştirmez. Zorunlu kontrollerden biri kalırsa çıkış kodu 1.
MIN="2.1.293"
HATA=0
tamam() { echo "tamam: $1"; }
eksik() { echo "EKSİK: $1"; HATA=1; }
uyari() { echo "uyarı: $1"; }

for k in git python3 bash; do
  if command -v "$k" >/dev/null 2>&1; then tamam "$k var"; else eksik "$k bulunamadı, kurun ve PATH'e ekleyin"; fi
done

if ! command -v claude >/dev/null 2>&1; then
  eksik "claude komutu bulunamadı, Claude Code'u kurun ve PATH'e ekleyin"
else
  tamam "claude var"
  SURUM="$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ -z "$SURUM" ]; then
    eksik "claude sürümü okunamadı, 'claude --version' çalışmıyor"
  elif [ "$(printf '%s\n%s\n' "$MIN" "$SURUM" | sort -V | head -1)" != "$MIN" ]; then
    eksik "claude sürümü $SURUM, en az $MIN gerekli, claude'u güncelleyin"
  else
    tamam "claude sürümü $SURUM (en az $MIN)"
  fi

  YARDIM="$(claude --help 2>&1)"
  if printf '%s\n' "$YARDIM" | grep -qE -- '--bg\b'; then tamam "claude --bg destekleniyor"
  else eksik "claude --bg desteklenmiyor, claude'u güncelleyin"; fi

  if claude agents --help 2>&1 | grep -q 'claude agents'; then tamam "claude agents destekleniyor"
  else eksik "claude agents desteklenmiyor, claude'u güncelleyin"; fi

  if printf '%s\n' "$YARDIM" | grep -A3 -- '--permission-mode' | grep -q '"auto"'; then
    tamam "otomatik izin modu (auto) yardım çıktısında görünüyor"
  else
    uyari "otomatik izin modu (auto) yardım çıktısında görünmüyor, baslat.sh --permission-mode auto kullanır"
  fi
fi

if [ "$#" -gt 0 ]; then
  if ! command -v python3 >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
    uyari "güven onayı kontrol edilemedi: python3 ve git gerekli"
  else
    for P in "$@"; do
      if [ ! -d "$P" ]; then uyari "proje klasörü yok: $P"; continue; fi
      # baslat.sh ile aynı mantık: git deposunda klasörün kendisi veya git kökü onaylı olmalı.
      if python3 - "$P" <<'PY'
import json,os,subprocess,sys
try:
    d=json.load(open(os.path.expanduser('~/.claude.json'))).get('projects',{})
except Exception: sys.exit(1)
ok=lambda a: d.get(a,{}).get('hasTrustDialogAccepted')
p=os.path.realpath(sys.argv[1])
k=subprocess.run(['git','-C',p,'rev-parse','--show-toplevel'],capture_output=True,text=True).stdout.strip()
if k: sys.exit(0 if ok(p) or ok(os.path.realpath(k)) else 1)
while p!='/':
    if ok(p): sys.exit(0)
    p=os.path.dirname(p)
sys.exit(1)
PY
      then tamam "güven onayı var: $P"
      else uyari "güven onayı yok: $P içinde bir kez claude açıp onay verin"; fi
    done
  fi
fi

if [ "$HATA" -eq 0 ]; then echo "sonuç: zorunlu kontroller geçti"; else echo "sonuç: zorunlu kontrollerde eksik var"; fi
exit "$HATA"
