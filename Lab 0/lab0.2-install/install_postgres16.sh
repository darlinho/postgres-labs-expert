#!/bin/bash
# install_postgres16.sh
# Installation manuelle et vérifications de base pour PostgreSQL 16 (Ubuntu 22.04 "jammy")

set -euo pipefail

echo "=== [1/6] Pré-requis & dépôt PGDG ==="
sudo apt update -y
sudo apt install -y wget ca-certificates lsb-release gnupg

# Ajout de la clé du dépôt PGDG (officiel)
if [ ! -f /etc/apt/trusted.gpg.d/pgdg.asc ]; then
  wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc >/dev/null
fi

# Ajout du dépôt (Ubuntu 22.04 = jammy)
if [ ! -f /etc/apt/sources.list.d/pgdg.list ]; then
  echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
fi

sudo apt update -y

echo "=== [2/6] Installation PostgreSQL 16 ==="
sudo apt install -y postgresql-16 postgresql-client-16 postgresql-contrib

echo "=== [3/6] Vérification service & version ==="
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl --no-pager --full status postgresql || true

psql -V

echo "=== [4/6] Première connexion & infos ==="
# Commandes utiles lancées via psql non interactif
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "SELECT version();"
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "SHOW data_directory;"
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "SHOW port;"
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "SHOW ssl;"

echo "=== [5/6] Listes de bases & rôles ==="
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "\l"
sudo -u postgres psql -v ON_ERROR_STOP=1 -c "\du"

echo "=== [6/6] Emplacements fichiers de conf ==="
CONF_DIR="/etc/postgresql/16/main"
DATA_DIR=$(sudo -u postgres psql -At -c "SHOW data_directory;")
echo "Fichiers de configuration : $CONF_DIR"
ls -la "$CONF_DIR"
echo "Répertoire de données    : $DATA_DIR"
ls -la "$DATA_DIR" | head -n 40

cat <<'EONOTE'

Notes:
- Les fichiers clés:
  * postgresql.conf : paramètres serveur (port/mémoire/logs…)
  * pg_hba.conf     : contrôle d'accès (qui/depuis où/comment)
  * pg_ident.conf   : mapping identités système ↔ rôles DB
- Par défaut sous Ubuntu, le data_directory est /var/lib/postgresql/16/main.
  Nous le déplacerons vers /pgdata/16/main dans un futur lab.

Installation terminée ✅
EONOTE
