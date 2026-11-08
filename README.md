# Fresh Linux Install

Script to run right after a fresh Linux install. It updates the system, cleans up unused packages and adds basic hardening with Fail2Ban and UFW.

Works on apt-based distributions: **Debian, Ubuntu and Pop!_OS**.

## What it does

1. Updates the package lists and runs a full upgrade (non-interactive, keeps your existing config files)
2. Removes unused packages and cleans the apt cache
3. Installs **Fail2Ban** and **UFW**
4. Configures Fail2Ban to read from journald on systems without `/var/log/auth.log` (e.g. Debian 12 and later), so the SSH jail actually starts
5. Sets UFW to deny incoming and allow outgoing traffic
6. Detects which port SSH is listening on and allows it, so you don't lock yourself out
7. Enables UFW and tells you if a reboot is required

## Usage

### Run directly from GitHub

```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/haxdoggy/Fresh-Linux-Install/main/script.sh)"
```

Or with curl:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/haxdoggy/Fresh-Linux-Install/main/script.sh)"
```

### Download, review, then run (recommended)

Never run a script from the internet without reading it first:

```bash
wget https://raw.githubusercontent.com/haxdoggy/Fresh-Linux-Install/main/script.sh
less script.sh
bash script.sh
```

The script uses `sudo` when it needs root, or runs as is if you are already root.

## License

[MIT](LICENSE)
