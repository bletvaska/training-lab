# provisioning of EC2 machines for trainings
# all recipes are expected to run as root on the target machine

set shell := ["bash", "-o", "errexit", "-o", "pipefail", "-o", "nounset", "-c"]

export DEBIAN_FRONTEND := "noninteractive"
export NEEDRESTART_MODE := "a"

# enable tracing of the scripts with: just DEBUG=1 <recipe>
export DEBUG := env("DEBUG", "")


# list available recipes
default:
    @just --list


# provision the machine for the Docker training
docker: base docker-packages docker-swap docker-engine docker-tools docker-dotfiles finish


# common setup for all trainings
base: base-packages base-hostname base-timezone base-expire base-ssh base-journald base-starship base-user


# check all scripts with shellcheck (run on the development machine)
lint:
    shellcheck --external-sources bootstrap.bash lib/*.bash scripts/*/*.bash files/*/etc/update-motd.d/*


[group('base')]
base-packages:
    scripts/base/packages.bash

[group('base')]
base-hostname:
    scripts/base/hostname.bash

[group('base')]
base-timezone:
    scripts/base/timezone.bash

[group('base')]
base-expire:
    scripts/base/expire.bash

[group('base')]
base-ssh:
    scripts/base/ssh.bash

[group('base')]
base-journald:
    scripts/base/journald.bash

[group('base')]
base-starship:
    scripts/base/starship.bash

[group('base')]
base-user:
    scripts/base/user.bash


[group('docker')]
docker-packages:
    scripts/docker/packages.bash

[group('docker')]
docker-swap:
    scripts/docker/swap.bash

[group('docker')]
docker-engine:
    scripts/docker/engine.bash

[group('docker')]
docker-tools:
    scripts/docker/tools.bash

[group('docker')]
docker-dotfiles:
    scripts/docker/dotfiles.bash


# remove unused packages and apt cache
[group('base')]
cleanup:
    apt-get autoremove --purge --yes
    apt-get clean

# clean up and reboot at the end of provisioning, common for all trainings
[group('base')]
finish: cleanup
    reboot
