#!/bin/bash
# Uppdaterar, uppgraderar och rensar systemet (Pop!_OS / Ubuntu / Debian)

set -e  # stoppa om något kommando misslyckas

echo "🔄 Uppdaterar paketlistor..."
sudo apt update

echo "⬆️  Uppgraderar paket..."
sudo apt full-upgrade -y

echo "🧹 Rensar oanvända paket..."
sudo apt autoremove --purge -y

echo "🗑️  Tömmer cache..."
sudo apt clean

echo "✅ Klart!"