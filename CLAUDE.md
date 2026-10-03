# training-lab – kontext pre Claude

Provisioning EC2 strojov (Ubuntu 26.04) pre školenia. Jedna launch template s `bootstrap.bash`
v user-data, konfigurácia cez tagy inštancie, zvyšok riadi `just`. Podrobnosti v `readme.md`,
história zmien v `changelog.md`. Lokálne (mimo gitu) môže byť `CLAUDE.local.md` s prostredím
a `notes/history.md` s priebehom doterajšej spolupráce.

## Dohody so používateľom (dodržiavať)

- **Žiadne zmeny bez výslovného pokynu.** Poznámka alebo otázka používateľa = vysvetlenie + návrh,
  nie úprava súborov. Platí aj pre vracanie vlastných zmien, commity, push a zásahy na serveroch.
- **Po každej zmene skriptu spustiť `just lint`** (shellcheck) a výsledok uviesť.
- **Clean code v bashi:** konštanty, malé pomenované funkcie, `main` a na konci source detection:
  ```bash
  # call the func only if the script is executed directly
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
      main "$@"
  fi
  ```
  Netriviálne kroky do funkcií, ale nerozdrobovať: 1–2 riadkové kroky ostávajú v `main`
  (preto má `bootstrap.bash` kroky priamo v `main`). Cesty, ktoré treba testovať, ako parameter
  funkcie (`readonly` konštanty sa v teste nedajú prepísať).
- **Komunikácia po slovensky**, kód, komentáre, `readme.md` a `changelog.md` po anglicky.
- **Commity:** po slovensky bez diakritiky, tvar `oblasť: popis`, prázdny riadok, odrážky,
  na konci `Co-Authored-By`. Najprv commit so zmenou, potom samostatný `changelog: vydanie X`.
- **Verzie:** CalVer `YYYY.M.PATCH` (mesiac bez nuly), changelog podľa Keep a Changelog,
  zmeny najprv do `[Unreleased]`. Bez git tagov (rovnako ako iné projekty používateľa).
- Názvy súborov malými písmenami (`readme.md`, `changelog.md`); `CLAUDE.md` je veľkými,
  lebo ho Claude Code inak automaticky nenačíta.
- Commit a push len na pokyn.

## Architektúra

- `bootstrap.bash` – user-data: `DPkg::Lock::Timeout`, `apt_update` s opakovaním, full-upgrade,
  `git` + `just`, klon do `/tmp/provisioning` (tmpfs, zmizne reštartom; pri chybe ostane na ladenie),
  commit do `/etc/training-lab-release`, tagy → premenné `PROFILE`, `TRAINING`, `STUDENT` (z `Name`),
  `LIFETIME`, potom `just <PROFILE>`. Voliteľne `USER_PASSWORD_HASH` (hash z `openssl passwd -6`).
- Tagy: `Profile` (predvolený `docker`; neplatný → `docker` + hláška; musí mať `scripts/<p>/`,
  nie `base`, `^[a-z0-9-]+$`), `Training`, `Name` (zatiaľ ako študent), `Lifetime` (`30 days`).
  V šablóne musí byť zapnuté *Allow tags in metadata* a *Shutdown behavior: Terminate*.
- `justfile` – recepty `docker`, `base`, kroky `base-*`, `docker-*`, `cleanup`, `finish`
  (`shutdown --reboot +1`, aby cloud-init stihol dokončiť fázu final), `lint`.
  Exportuje `DEBIAN_FRONTEND`, `NEEDRESTART_MODE`, `DEBUG` (`just DEBUG=1 <recept>` zapne xtrace)
  a `BASH_ENV=lib/include.bash`.
- `lib/include.bash` – funkcia `include` (ako `load` v bats, relatívne k skriptu). Volanie
  `include ../../lib/common || exit 1`. Nie `import` (ImageMagick) ani `load` (bats).
  Knižnica sa načíta vo funkcii → v nej nepoužívať `declare`/`local` pre globálne premenné.
- `lib/common.bash` – `set -o errexit/pipefail/nounset/errtrace`, ERR trap s miestom chyby,
  `PROJECT_ROOT`, `USER_NAME`, `USER_HOME` (veľké písmená, inak shellcheck hlási SC2154),
  funkcie `log`, `fetch`, `get_github_latest_release`, `apt_install`, `download_binary`,
  `install_file`, `install_user_file`, `append_line_if_not_exists`.
- `scripts/<profil>/*.bash` – jeden krok = jeden skript, opakovateľné spustenie (idempotentné).
- `files/<profil>/` zrkadlí cieľový systém, `files/<profil>/home/` → domov používateľa `ubuntu`.

## Poučenia (overené)

- `apt-get` na zámok dpkg nečaká, `apt` áno; `DPkg::Lock::Timeout` pomôže pre install/upgrade,
  nie pre zámok zoznamov pri `update` (preto opakovanie).
- Zámok po štarte môže držať aj **AWS SSM Patch Manager** (dokument `PatchLinux`),
  ktorý inštaluje `python3-apt` a patchuje.
- Okamžitý `reboot` v user-data zabil `cloud-final` (`BrokenPipeError`) → odložený reštart.
- IMDS tagy fungujú vrátane medzier a `@`; zobrazujú sa aj `aws:ec2launchtemplate:id/version`.
  Zápis tagov zo stroja by vyžadoval IAM rolu + AWS CLI (zamietnuté).
- `dockerd --validate` nekontroluje kľúče v sekcii `builder`; `defaultKeepStorage` podľa dokumentácie.
- Rootless podman 5 potrebuje `passt` (+ `aardvark-dns`), pri `--no-install-recommends` chýbajú.
- `sshd` berie prvú hodnotu; `60-cloudimg-settings.conf` vypína heslá → náš drop-in `10-password.conf`.
- Docker používa containerd image store (`/var/lib/containerd`), nie `/var/lib/docker`.

## Otvorené body / ďalšie kroky

1. **Banery v logu** (štart, koniec, chyba) v `bootstrap.bash` – navrhnuté, čaká na schválenie;
   majú obsahovať profil, `Training`, `Name`, verziu, trvanie, prípadne verziu šablóny.
2. **MOTD** s `Training` a študentom (`STUDENT`).
3. **Balíky ako dáta**: napr. `profiles/<p>/packages.txt` + spoločný inštalátor.
4. **Profil `kubernetes`** – používateľ má podobný skript, cestu zatiaľ neposlal;
   pri kubeadm pozor na swap (je preto v profile `docker`, nie `base`).
5. **`just launch`** na vývojovom stroji (AWS CLI `run-instances` s tagmi, `Name=student@training`).
6. Voliteľné: `require("shellcheck")` v `lint` (odložené), zjednodušenie `scripts/docker/tools.bash`,
   `apt_update` aj v `lib/common.bash`.
7. Po každej zmene `bootstrap.bash` treba aktualizovať user-data v launch template.
