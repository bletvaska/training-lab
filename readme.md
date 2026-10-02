# training-lab

Provisioning of EC2 machines (Ubuntu) for trainings.

## Usage

1. Copy `bootstrap.bash` to the user-data of the EC2 launch template.
2. Set the variables at its top: `repository`, `branch`, `training` and `LIFETIME`.
   Optionally uncomment `USER_PASSWORD_HASH` (generate the hash with `openssl passwd -6`)
   to set the user password and enable SSH login with it. Without it, only SSH keys work.
3. Launch the instance. The bootstrap updates the system, installs `git` and `just`,
   clones this repository to `/tmp/provisioning` and runs `just <training>`.
   The machine reboots at the end, which also removes the repository from `/tmp`.
   If the provisioning fails, the machine does not reboot and the repository stays there.

The commit used for the provisioning is stored in `/etc/training-lab-release`.

## Lifetime

The machine powers off at the end of its lifetime (`LIFETIME`, 30 days by default)
by `expire.timer`. Set **Shutdown behavior** to **Terminate** in the launch template
(`InstanceInitiatedShutdownBehavior=terminate`), so the instance is terminated, not only stopped.
Note that any power off from inside the machine then terminates it, e.g. `sudo poweroff`.
Reboot is not affected.

```
systemctl list-timers expire.timer   # show the date
systemctl edit expire.timer          # change it ([Timer] OnCalendar=...)
```

The output of the provisioning is in `/var/log/cloud-init-output.log`.

## Structure

```
bootstrap.bash      user-data for the launch template
justfile            recipes; `just --list` shows them
lib/common.bash     settings and helper functions sourced by all scripts
scripts/<profile>/  provisioning steps, one script per step
files/<profile>/    files installed to the machine; the path mirrors the target,
                    files/<profile>/home/ goes to the home directory of the user
```

Profiles: `base` (common for all trainings), `docker`.

Each step can be run separately as root on the target machine, e.g. `just docker-tools`.

Scripts load the libraries with `include ../../lib/common || exit 1` (similar to `load` in bats),
which is relative to the script. `just` makes the `include` function available through
`BASH_ENV`. Without it the script stops immediately. To run a script without `just`, set it yourself:

```
BASH_ENV=lib/include.bash scripts/docker/tools.bash
```

## Debugging

Scripts print only their steps and the place of an error. To trace all commands,
set the `DEBUG` variable:

```
just DEBUG=1 docker-tools
```

## Development

```
just lint    # shellcheck of all scripts
```
