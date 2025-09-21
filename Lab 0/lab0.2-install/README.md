# Lab 0.2 — Installation de PostgreSQL 16 & Découverte des fichiers

## 🎯 Objectifs
- Installer PostgreSQL 16 depuis le dépôt officiel PGDG
- Découvrir les fichiers et répertoires clés de PostgreSQL
- Se connecter avec `psql` et faire les premiers checks
- Modifier un paramètre simple (port) et tester

---

## 📦 Pré-requis
- Ubuntu 22.04 LTS (jammy)
- Serveur préparé avec **Lab 0.1** (mises à jour + hygiène système)
- Accès `sudo`

---

## 🛠️ Étapes manuelles d’installation

### 1) Mettre à jour le système
```bash
sudo apt update && sudo apt upgrade -y
```

### 2) Installer les dépendances nécessaires
```bash
sudo apt install -y wget ca-certificates gnupg lsb-release
```

### 3) Ajouter la clé GPG du dépôt PostgreSQL
```bash
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc |   sudo tee /etc/apt/trusted.gpg.d/pgdg.asc
```

### 4) Ajouter le dépôt PostgreSQL (PGDG)
```bash
echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" |   sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
```

### 5) Installer PostgreSQL 16
```bash
sudo apt install -y postgresql-16 postgresql-client-16 postgresql-contrib
```

### 6) Vérifier que le service est actif
```bash
sudo systemctl status postgresql
```
👉 Le statut doit afficher **`active (running)`**.

---

## 🚀 Première utilisation de PostgreSQL

### 1) Vérifier la version de `psql`
```bash
psql -V
# Exemple : psql (PostgreSQL) 16.4
```

### 2) Se connecter avec l’utilisateur `postgres`
```bash
sudo -i -u postgres
psql
```

Dans le shell `psql`, exécuter :

```sql
\conninfo            -- infos de connexion (hôte, port, utilisateur)
\l                   -- liste des bases
\du                  -- liste des rôles
SHOW data_directory; -- chemin du répertoire de données
SHOW port;           -- port actuel
SHOW ssl;            -- SSL activé ou non
```

Pour quitter :
```
\q
exit
```

---

## 📁 Découverte des fichiers de configuration

Lister le contenu du répertoire de config :
```bash
ls -l /etc/postgresql/16/main
```

Fichiers importants :
- **`postgresql.conf`** → paramètres serveur (mémoire, port, logs…)
- **`pg_hba.conf`** → règles d’accès (qui peut se connecter, depuis où, comment)
- **`pg_ident.conf`** → mapping d’identités système ↔ rôles PostgreSQL

Vérifier le répertoire de données réel :
```bash
sudo -u postgres psql -c "SHOW data_directory;"
```
👉 Par défaut : `/var/lib/postgresql/16/main`

---

## 🧪 Exercice pratique : changer le port

1. Ouvrir le fichier de config :
```bash
sudo nano /etc/postgresql/16/main/postgresql.conf
```

2. Décommenter et modifier :
```
port = 5433
```

3. Redémarrer PostgreSQL :
```bash
sudo systemctl restart postgresql
```

4. Tester la connexion sur le nouveau port :
```bash
sudo -u postgres psql -p 5433 -c "SELECT version();"
```

5. (Optionnel) Revenir au port par défaut (5432) et redémarrer.

---

## ✅ Résultats attendus
- `psql -V` retourne `psql (PostgreSQL) 16.x`
- `\conninfo`, `\l`, `\du` fonctionnent dans `psql`
- `SHOW data_directory;` retourne `/var/lib/postgresql/16/main`
- `SHOW ssl;` retourne `on`
- Connexion réussie sur le **port modifié (5433)**

---

## 🧠 Points clés à retenir
- L’utilisateur système **`postgres`** correspond au rôle DB **`postgres`** (superuser).
- `postgresql.conf` → configuration globale du serveur.
- `pg_hba.conf` → règles d’authentification et d’accès.
- `pg_ident.conf` → mapping identités (utile pour `peer` et `ident`).
- Le répertoire `data_directory` contient tout (catalogues, tables, WAL).
- Après modification de la config : toujours **redémarrer ou recharger** le service.

---

## 🔜 Prochain Lab (1.1)
- Découvrir les **sauvegardes logiques** avec `pg_dump` / `pg_restore`
- Cloner une base d’une instance à une autre
