# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Calendar Versioning](https://calver.org/) (`YYYY.M.PATCH`).

## [Unreleased]

### Fixed

- Scripts run with `HOME=/root` instead of the user's home directory, so tools run as root
  during the provisioning no longer create directories owned by root there;
  k9s failed with permission denied on `~/.local/state`.

## [2026.10.8] - 2026-10-12

### Fixed

- needrestart does not restart `cloud-init-main.service` during the provisioning;
  it restarted cloud-init after apt runs of AWS SSM, because the exception of Ubuntu
  covers only the service names of older cloud-init.

## [2026.10.7] - 2026-10-12

### Changed

- User password is set from the tag `Password` (plain text) instead of the hash
  in `USER_PASSWORD_HASH`, so the user-data contains no settings at all;
  SSH password authentication is enabled only with the password.
- The password is not traced in the debug output.

## [2026.10.6] - 2026-10-12

### Added

- Profile `kubernetes`: k3s (with its kubectl), helm, kompose, k9s, kubecolor, kubeconform,
  stern, popeye, kubectx/kubens, fzf, krew, bash completions, kubeconfig for the user
  (`KUBECONFIG` in `.bashrc.kubernetes`), aliases, starship config and YAML templates.
- `lib/common.bash`: `install_binary_from_github`, `install_completion`.

### Changed

- `get_github_latest_release` fails, if the release asset is missing or ambiguous.
- Starship is installed from the Ubuntu package instead of its install script,
  recipe `base-starship` removed.

## [2026.10.5] - 2026-10-02

### Added

- Provisioning is configured by the tags of the instance (`Profile`, `Training`, `Name`,
  `Lifetime`), so one launch template serves all trainings; the default profile is `docker`.

### Fixed

- `apt-get` waits for the dpkg lock held by other apt processes after boot
  (`DPkg::Lock::Timeout`) and `apt-get update` is retried, instead of failing.

## [2026.10.4] - 2026-10-02

### Changed

- `bootstrap.bash` no longer traces its commands with `xtrace`.

### Fixed

- Reboot at the end of the provisioning is delayed by one minute, so cloud-init
  finishes its final stage; the immediate reboot killed it (`BrokenPipeError`).

## [2026.10.3] - 2026-10-02

### Changed

- Scripts in `scripts/` are split into small functions called from `main`
  and `bootstrap.bash` has its steps in `main`; `main` runs only when the script
  is executed directly, so the scripts can be sourced and tested.
- Scripts load libraries with `include ../../lib/common` relative to their location,
  `just` provides the `include` function through `BASH_ENV`; without it the scripts stop.
- Global variables of `lib/common.bash` renamed to `PROJECT_ROOT`, `USER_NAME`
  and `USER_HOME`; timezone moved to `scripts/base/timezone.bash`.

## [2026.10.2] - 2026-10-02

### Added

- `vscode-server-cleanup.bash`: removes old versions of VS Code Server from the user's
  home directory every midnight, keeps the two latest ones.

## [2026.10.1] - 2026-10-02

### Added

- `bootstrap.bash` for the user-data of the EC2 launch template: updates the system,
  installs `git` and `just`, clones the repository to `/tmp/provisioning`
  and runs the training recipe.
- Commit used for the provisioning is stored in `/etc/training-lab-release`.
- Limited lifetime of the machine (`LIFETIME`, 30 days by default): `expire.timer` powers it off
  and the message of the day shows the date.
- `justfile` with the `docker`, `base`, `lint`, `cleanup` and `finish` recipes
  and a separate recipe for each provisioning step.
- `lib/common.bash` with shared settings and helper functions.
- Location of a failed command is logged; tracing of commands is enabled with `just DEBUG=1 <recipe>`.
- Profile `base`: system packages, hostname from public IP address, timezone,
  SSH password authentication, journald size limit, starship, user password and dotfiles.
- Profile `docker`: container packages (podman with `passt` and `aardvark-dns`),
  2G swap file, Docker with limited log size and build cache, grype, dive, dry,
  hadolint and bash aliases.

### Changed

- Provisioning migrated from the single `provisioning-docker.bash` script
  into separate scripts and configuration files.
- User password is passed as a hash in the optional `USER_PASSWORD_HASH` variable
  instead of being stored in the script. SSH password authentication is enabled
  only when it is set.
- Dotfiles are part of the repository instead of being downloaded over HTTP.
- Hostname is set on reboot by `/etc/cron.d/hostname` instead of a line in `/etc/crontab`.
- Additions to `.bashrc` moved to `.bashrc.local`.
- Steps can be run repeatedly without duplicating lines in `/etc/fstab` and `.bashrc`.

