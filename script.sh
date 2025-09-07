#!/bin/bash
# Enkel underhåll + säkerhetsverktyg för Pop!_OS / Ubuntu / Debian

set -e

# -------------------------------
# Kontrollera om curl eller wget finns
# -------------------------------
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
# Installera fail2ban och UFW
# -------------------------------
echo "🛡️  Installerar fail2ban och UFW..."
sudo apt install -y fail2ban ufw

# -------------------------------
# Konfigurera UFW
# -------------------------------
echo "⚙️  Aktiverar och konfigurerar UFW..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp   # SSH
sudo ufw --force enable

echo "✅ Klar! Systemet är uppdaterat och säkerhetsverktyg installerade."
