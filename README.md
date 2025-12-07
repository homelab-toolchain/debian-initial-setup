# Debian Initial Setup

Bootstrap a fresh Debian host with baseline packages and optional extras (timezone, Docker, IPv6 settings) via a single non-interactive script.

## What this script does
1. Update and upgrade apt packages.
2. Install base tools: curl, net-tools, ca-certificates, git, nano.
3. Optionally set the system timezone (defaults to Etc/UTC when the flag is provided without a value).
4. Optionally install Docker from the official repository after removing conflicting packages.
5. Optionally disable IPv6 via sysctl.
6. Reboot the system.

## Requirements
- Debian-based system with `apt` and systemd tools (`timedatectl`).
- Root shell (or equivalent privileges).
- Internet connectivity.

## Usage
Run everything with defaults (no optional steps):
```
wget -qO- https://github.com/homelab-toolchain/debian-initial-setup/raw/refs/heads/main/debian-initial-setup.sh | bash
```

Enable optional steps by passing flags after `bash -s` (any presence of optional args turns them on):
```
wget -qO- https://github.com/homelab-toolchain/debian-initial-setup/raw/refs/heads/main/debian-initial-setup.sh | bash -s setTimeZone=Europe/Amsterdam installDocker disableIPv6
```

### Optional flags
- `setTimeZone[=Region/City]` – set timezone; omit value to use `Etc/UTC`.
- `installDocker` – install Docker Engine/CLI, Buildx, and Compose from the Docker repo; removes distro Docker/Podman packages first.
- `disableIPv6` – write sysctl config to disable IPv6.

### Local execution
```
chmod +x debian-initial-setup.sh
sudo ./debian-initial-setup.sh [flags]
```

## Notes
- Script is non-interactive and reboots at the end even if optional steps are skipped.
- Docker install fetches keys to `/etc/apt/keyrings/docker.asc` and adds `docker.list` under `sources.list.d`.
- IPv6 disablement writes to `/etc/sysctl.d/99-disable-ipv6.conf`; adjust or remove if not desired.
