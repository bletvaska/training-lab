# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Calendar Versioning](https://calver.org/) (`YYYY.M.PATCH`).

## [Unreleased]

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

