# Süper ajan kiti

Farklı projelerdeki ayrı Claude Code oturumlarını tek bir süper ajandan yönetin. Siz yalnızca süper ajanla konuşursunuz. Süper ajan her işi kendi projesinde ayrı bir oturumda başlatır, biteni kontrol ettirir, eksik olanı geri gönderir, kararınız gereken yerde size sorar ve geçen kod değişikliğini projeye ekletir.

Fikir: DeepSeek'in süper ajan yaklaşımı ([dsh-superagent-prototype](https://github.com/deepseek-ai/dsh-superagent-prototype)). Bu kit onun kodu değildir; fikrin Claude Code'a uyarlanmış, farklı projelere yayılmış hâlidir.
Durum: Deneysel. Gerçek işlerle Claude Code 2.1.293 ve Linux'ta denendi; betikler her güncellemede Linux, macOS ve Windows'ta otomatik test edilir.

## Gereksinimler
- Claude Code 2.1.293 veya sonrası. `claude --bg` ve `claude agents` (araştırma önizlemesi) çalışmalı.
- Hesabınızda otomatik izin modu (`--permission-mode auto`) açık olmalı.
- `git` 2.38 veya sonrası, `bash` ve Python 3.8 veya sonrası (`python3` ya da `python`).
- Linux ve macOS'ta terminalde çalışır; macOS'un kendi bash 3.2 sürümü yeterli. Windows'ta komutları Git for Windows ile gelen Git Bash'te çalıştırın.
- Platform durumu: Betikler (pano, durum, gözcü, güven ve sürüm kontrolü, birleştirme provası) üç sistemde de otomatik testten geçiyor. Gerçek Claude Code oturumlarıyla uçtan uca deneme şimdilik yalnız Linux'ta yapıldı.
- Kod işleri için projenin git deposu olması gerekir.

## Kurulum
1. Depoyu `merkez` adıyla klonlayın. Depo kökü doğrudan merkez klasörüdür; `isler/` klasörü içinde hazır gelir. İlk adım `./kontrol.sh` çalıştırmaktır:
   ```bash
   git clone https://github.com/fornhere/super-ajan merkez
   cd merkez
   ./kontrol.sh
   ```
2. İş vereceğiniz her proje klasöründe bir kez `claude` açıp güven onayı verin. Onay yoksa arka plan oturumu başlamaz, süper ajan size bildirir.

## Kullanım
1. `merkez` içinde normal Claude Code açın, kartları yazdırın: `/is-karti yapılacak iş`. Örnekler `ornek-kartlar/` içinde. Her kartta `Proje:` satırı işin klasörünü söyler.
2. Kartı okuyun, uygunsa `Durum: hazir` yapın (Türkçe karakter olmadan).
3. Süper ajanı açın ve "hazır kartları başlat" yazın:

```bash
claude --agent super-ajan --name super-ajan --permission-mode auto
```

Kartların durumu: `./pano.sh` · Canlı tablo: `./pano.sh --izle` · Bütün oturumlar: `claude agents`

## Akış
işçi → incelemeci → (kod işinde) doğrulayıcı → birleştirme provası → birleştirici → bitti.
Geçemeyen iş aynı işçiye döner; üç turda geçmezse süper ajan size sorar. Gözcü (`gozcu.sh`) model harcamadan on dakikada bir oturumlara bakar, kapanan veya takılanı süper ajana bildirir.

## Birleştirme
Birleştirici, incelemeden ve doğrulamadan geçen dalı ana daldan açtığı geçici bir kopyada birleştirir. Projenizin AGENTS.md veya CLAUDE.md dosyasında birleştirme kuralı (tam test turu vb.) varsa onu uygular, yoksa kartın kontrollerini çalıştırır. Hepsi geçerse ana dalı ileri sarar, geçmezse ana dala dokunmaz. Push yapmaz. Aynı projede aynı anda tek birleştirici çalışır.
Birleştirmeyi kendiniz yapmak isterseniz süper ajana "birleştirmeden önce sor" deyin. Önemli projelerde bunu öneririz.

## Dikkat
- Her oturum limitinizden ayrı harcar. Tek iş için kurmayın.
- Oturumlar bilgisayar kapanınca durur.
- Bir bilgisayarda aynı anda tek süper ajan çalıştırın; işçiler `super-ajan` adına mesaj atar.
- Otomatik mod izin sorularını azaltır. Oturumlar internetten okudukları metinden etkilenebilir; önemli işlerde ayrı bir işletim sistemi hesabı veya kapsayıcı kullanın.
- Süper ajanın dosya yazma aracı yok, ama kabuk komutu çalıştırabilir. Bu tam bir güvenlik sınırı değil, davranış kuralıdır. Arada bir biten işlerden birini açıp kendiniz bakın.
- `.env` ve anahtar dosyaları işçilere yasaktır, ama bunu kural sağlar, kilit değil.
- Kod işlerinde arka plan oturumları projenizin içinde `.claude/worktrees/` klasörü açar. Bu klasörü projenizin `.gitignore` dosyasına ekleyin. İş bitince eski dalları ve worktree'leri `git worktree list` ile görüp kendiniz temizleyin.

## Parçalar
- Ajanlar: süper ajan (`.claude/agents/`), işçi, incelemeci, doğrulayıcı, birleştirici (`roller/`).
- Programlar, model harcamaz: `pano.sh`, `gozcu.sh`, `birlestirme-hazirla.sh`. Yardımcılar: `baslat.sh` oturum açar, `durum.sh` kart durumunu değiştirir.

## Lisans ve sürümler
MIT lisansı: `LICENSE`. Sürüm notları: `CHANGELOG.md`.

## English summary
**Super-agent kit** lets you manage separate Claude Code sessions spread across different projects through a single "super agent". You talk only to the super agent. It starts each job in its own session inside the job's project, has finished work reviewed, sends incomplete work back, asks you only when a decision is yours, and has accepted code changes merged. It is experimental. The documentation above is in Turkish.

This kit is not DeepSeek's code. It is an adaptation of the idea in [deepseek-ai/dsh-superagent-prototype](https://github.com/deepseek-ai/dsh-superagent-prototype) to Claude Code.

**Requirements**
- Claude Code 2.1.293 or later, with `claude --bg` and `claude agents` (research preview) working.
- Auto permission mode (`--permission-mode auto`) enabled on your account.
- `git` 2.38+, `bash` and Python 3.8+ (`python3` or `python`). Works in a Linux or macOS terminal (macOS's built-in bash 3.2 is enough); on Windows use Git Bash from Git for Windows.
- The scripts are tested automatically on Linux, macOS and Windows on every change. End-to-end runs with real Claude Code sessions have so far been done on Linux only.
- Code jobs require the project to be a git repository.

**Use in three steps**
1. Clone and check: `git clone https://github.com/fornhere/super-ajan merkez`, then run `./kontrol.sh` inside it. In each project you will give jobs to, open `claude` once and accept the trust prompt.
2. In `merkez`, open Claude Code and write job cards with `/is-karti <the job>` (examples in `ornek-kartlar/`). Read each card and, if fine, set `Durum: hazir` (no Turkish characters).
3. Start the super agent and say "start the ready cards" (in Turkish: "hazır kartları başlat"):
   ```bash
   claude --agent super-ajan --name super-ajan --permission-mode auto
   ```

Each session spends from your usage limit separately. Auto mode reduces permission prompts, and sessions may be affected by text they read from the internet, so use a separate OS account or container for important work.
