#!/bin/bash
# Hardened setup för Pop!_OS / Ubuntu / Debian

set -e

# -------------------------------
# Kontrollera om curl eller wget finns
# -------------------------------
DOWNLOAD_TOOL=""
if command -v curl &> /dev/null; then
    DOWNLOAD_TOOL="curl -s"
elif command -v wget &> /dev/null; then
    DOWNLOAD_TOOL="wget -qO-"
else
    echo "📦 Varken curl eller wget hittades. Installerar curl..."
    sudo apt update
    sudo apt install -y curl
    DOWNLOAD_TOOL="curl -s"
fi

echo "✔️ Använder nedladdningsverktyg: $DOWNLOAD_TOOL"

# -------------------------------
# Uppdatera och uppgradera systemet
# -------------------------------
echo "🔄 Uppdaterar paketlistor..."
sudo apt update

echo "⬆️  Uppgraderar paket..."
sudo apt full-upgrade -y

echo "🧹 Rensar oanvända paket..."
sudo apt autoremove --purge -y
sudo apt clean

# -------------------------------
# Installera säkerhetsverktyg
# -------------------------------
echo "🛡️  Installerar säkerhetsverktyg..."
sudo apt install -y fail2ban ufw auditd rkhunter unattended-upgrades

# -------------------------------
# Konfigurera UFW
# -------------------------------
echo "⚙️  Konfigurerar UFW..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp   # SSH
sudo ufw --force enable

# -------------------------------
# Konfigurera Fail2Ban
# -------------------------------
echo "🔒 Startar och aktiverar Fail2Ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# -------------------------------
# Säker SSH
# -------------------------------
echo "🔑 Konfigurerar SSH..."
sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# -------------------------------
# Automatisk säkerhetsuppdatering
# -------------------------------
echo "⚡ Aktiverar automatiska säkerhetsuppdateringar..."
sudo dpkg-reconfigure -plow unattended-upgrades

# -------------------------------
# Hårda filrättigheter
# -------------------------------
echo "🛡️ Begränsar rättigheter i hemkataloger..."
chmod 700 $HOME

# -------------------------------
# Kontrollera rootkit
# -------------------------------
echo "🔍 Initierar rootkit-kontroll..."
sudo rkhunter --update
sudo rkhunter --propupd
sudo rkhunter --check --sk

echo "✅ Grundläggande härdning klar!"
