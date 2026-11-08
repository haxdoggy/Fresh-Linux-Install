#!/usr/bin/env bash
# Enkel underhåll + säkerhetsverktyg för Debian / Ubuntu / Pop!_OS
# Uppdaterar systemet, städar bort oanvända paket och installerar fail2ban och UFW.

set -euo pipefail

# -------------------------------
# Förkontroller
# -------------------------------
if [ "$(id -u)" -eq 0 ]; then
    SUDO=()
elif command -v sudo &> /dev/null; then
    SUDO=(sudo)
else
    echo "❌ Kör skriptet som root eller installera sudo först." >&2
    exit 1
fi

if ! command -v apt-get &> /dev/null; then
    echo "❌ Skriptet stöder bara apt-baserade system (Debian, Ubuntu, Pop!_OS)." >&2
    exit 1
fi

# Kör apt-get utan interaktiva frågor och behåll befintliga konfigurationsfiler
apt_get() {
    "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get -y \
        -o Dpkg::Options::=--force-confdef \
        -o Dpkg::Options::=--force-confold \
        "$@"
}

# -------------------------------
# Uppdatera och uppgradera systemet
# -------------------------------
echo "🔄 Uppdaterar paketlistor..."
apt_get update

echo "⬆️  Uppgraderar paket..."
apt_get full-upgrade

echo "🧹 Rensar oanvända paket..."
apt_get autoremove --purge
apt_get clean

# -------------------------------
# Installera fail2ban och UFW
# -------------------------------
echo "🛡️  Installerar fail2ban och UFW..."
apt_get install fail2ban ufw

# System som bara loggar till journald (t.ex. Debian 12 och senare) saknar
# /var/log/auth.log. Då måste sshd-jailen läsa från systemd, annars startar
# inte fail2ban.
if [ ! -f /var/log/auth.log ]; then
    echo "📝 Hittade ingen /var/log/auth.log – låter fail2ban läsa från journald..."
    apt_get install python3-systemd
    printf '[sshd]\nbackend = systemd\n' | "${SUDO[@]}" tee /etc/fail2ban/jail.d/sshd-systemd.local > /dev/null
fi

if command -v systemctl &> /dev/null; then
    "${SUDO[@]}" systemctl enable fail2ban &> /dev/null || true
    "${SUDO[@]}" systemctl restart fail2ban \
        || echo "⚠️  fail2ban startade inte – kontrollera med: sudo systemctl status fail2ban"
fi

# -------------------------------
# Konfigurera UFW
# -------------------------------
echo "⚙️  Aktiverar och konfigurerar UFW..."

# Ta reda på vilken port SSH lyssnar på så att du inte låser ute dig själv
SSH_PORTS=()
if [ -x /usr/sbin/sshd ]; then
    mapfile -t SSH_PORTS < <("${SUDO[@]}" /usr/sbin/sshd -T 2> /dev/null | awk '$1 == "port" { print $2 }' | sort -u)
fi
if [ "${#SSH_PORTS[@]}" -eq 0 ]; then
    SSH_PORTS=(22)
fi

"${SUDO[@]}" ufw default deny incoming
"${SUDO[@]}" ufw default allow outgoing
for port in "${SSH_PORTS[@]}"; do
    "${SUDO[@]}" ufw allow "${port}/tcp" comment 'SSH'
done
"${SUDO[@]}" ufw --force enable

echo "✅ Klar! Systemet är uppdaterat och säkerhetsverktyg installerade."
echo "   SSH är öppet på port: ${SSH_PORTS[*]}"

if [ -f /var/run/reboot-required ]; then
    echo "🔁 En omstart krävs för att slutföra uppdateringarna."
fi
