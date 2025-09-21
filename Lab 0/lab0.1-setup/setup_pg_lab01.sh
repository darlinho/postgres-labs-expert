#!/bin/bash
set -e

echo "=== Mise à jour du système ==="
sudo apt update -y && sudo apt upgrade -y

echo "=== Installation outils de base ==="
sudo apt install -y ufw htop vim curl wget

echo "=== Vérification utilisateur postgres ==="
if id "postgres" &>/dev/null; then
    echo "Utilisateur postgres existe ✅"
    sudo usermod -s /usr/sbin/nologin postgres
else
    echo "Utilisateur postgres non trouvé, création..."
    sudo adduser --disabled-password --gecos "" postgres
    sudo usermod -s /usr/sbin/nologin postgres
fi

echo "=== Création répertoire PostgreSQL ==="
sudo mkdir -p /pgdata/16/main
sudo chown -R postgres:postgres /pgdata
sudo chmod 700 /pgdata/16/main

echo "=== Configuration noyau (sysctl) ==="
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF
# PostgreSQL tuning minimal
vm.swappiness=1
vm.dirty_ratio=10
vm.overcommit_memory=2
EOF

sudo sysctl -p

echo "=== Configuration UFW ==="
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

echo "=== Résumé de l’installation ==="
lsb_release -a
uname -r
ls -ld /pgdata/16/main
sysctl -a | grep -E "swappiness|dirty_ratio|overcommit_memory"
sudo ufw status verbose

echo "=== Lab 0.1 terminé ✅ ==="
