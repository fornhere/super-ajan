# Süper ajan kiti

Farklı projelerdeki ayrı Claude Code oturumlarını tek bir süper ajandan yönetin. Siz yalnızca süper ajanla konuşursunuz. Süper ajan her işi kendi projesinde ayrı bir oturumda başlatır, biteni kontrol ettirir, eksik olanı geri gönderir, kararınız gereken yerde size sorar ve geçen kod değişikliğini projeye ekletir.

Fikir: DeepSeek'in süper ajan yaklaşımı. Bu kit onun Claude Code'a uyarlanmış, farklı projelere yayılmış hâlidir.
Durum: Deneysel. Claude Code 2.1.293 ile Linux'ta denendi.

## Gereksinimler
- Claude Code 2.1.293 veya sonrası. `claude --bg` ve `claude agents` (araştırma önizlemesi) çalışmalı.
- Hesabınızda otomatik izin modu (`--permission-mode auto`) açık olmalı.
- `git`, `bash` ve `python3`. Linux'ta denendi; macOS'ta çalışması beklenir ama denenmedi. Windows'ta WSL gerekir.
- Kod işleri için projenin git deposu olması gerekir.

## Kurulum
1. Bu klasörü `merkez` adıyla bir yere kopyalayın ve içinde `isler/` klasörünü oluşturun.
2. İş vereceğiniz her proje klasöründe bir kez `claude` açıp güven onayı verin. Onay yoksa arka plan oturumu başlamaz, süper ajan size bildirir.

## Kullanım
1. `merkez` içinde normal Claude Code açın, kartları yazdırın: `/is-karti yapılacak iş`. Örnekler `ornek-kartlar/` içinde. Her kartta `Proje:` satırı işin klasörünü söyler.
2. Kartı okuyun, uygunsa `Durum: hazir` yapın (Türkçe karakter olmadan).
3. Süper ajanı açın ve "hazır kartları başlat" yazın:

```bash
claude --agent super-ajan --name super-ajan --permission-mode auto
```

Kartların durumu: `./pano.sh` · Bütün oturumlar: `claude agents`

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

## Parçalar
- Ajanlar: süper ajan (`.claude/agents/`), işçi, incelemeci, doğrulayıcı, birleştirici (`roller/`).
- Programlar, model harcamaz: `pano.sh`, `gozcu.sh`, `birlestirme-hazirla.sh`. Yardımcılar: `baslat.sh` oturum açar, `durum.sh` kart durumunu değiştirir.
