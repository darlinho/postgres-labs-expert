# Lab 1.1 — Scripts de provisionning, backup et restauration

Ces scripts automatisent les étapes du Lab 1.1 à l'aide d'un fichier `.env` pour gérer les variables.

---

## 📦 Fichiers

- `.env.example` → modèle de configuration (à copier en `.env`)
- `provision.sh` → crée la base de test (`shop`) et insère des données
- `backup.sh` → effectue un dump logique (custom, directory ou plain)
- `restore.sh` → restaure un dump dans une base cible (`shop_copy` par défaut)

---

## ⚙️ Configuration (.env)

Exemple (voir `.env.example`) :

```env
PGHOST=localhost
PGPORT=5432
PGUSER=postgres
PGDATABASE=shop
PGPASSWORD=

BACKUP_DIR=/tmp/pg_backups
DUMP_FORMAT=c   # c=custom, d=directory, p=plain
TABLE_FILTER=   # ex: public.products
RESTORE_DATABASE=shop_copy

SCHEMA_ONLY=false
DATA_ONLY=false
JOBS=2
PGCONNECT_TIMEOUT=5
```

---

## 🚀 Utilisation

### 1) Préparer l'environnement
```bash
cp .env.example .env
nano .env
```

### 2) Créer la base de test et insérer des données
```bash
./provision.sh
```

### 3) Effectuer un backup
```bash
./backup.sh
```
- Sauvegarde au format choisi (custom/directory/plain)
- Le chemin du dernier backup est stocké dans `${BACKUP_DIR}/latest.path`

### 4) Restaurer un backup
```bash
./restore.sh              # restaure le dernier backup
./restore.sh /chemin.dump # restaure un dump custom
./restore.sh /chemin/dir  # restaure un dump directory
./restore.sh /chemin.sql  # restaure un fichier SQL
```

---

## 🧪 Exemples pratiques

- Restaurer uniquement la table `products` :
```bash
TABLE_FILTER=public.products ./restore.sh
```

- Faire un dump uniquement du schéma :
```bash
SCHEMA_ONLY=true ./backup.sh
```

- Faire un dump uniquement des données :
```bash
DATA_ONLY=true ./backup.sh
```

---

## ✅ Résultats attendus

- Une base `shop` avec une table `products` (3 lignes d'exemple)
- Un fichier de backup créé dans `${BACKUP_DIR}`
- Une base `shop_copy` restaurée avec les mêmes données

---

## 🔜 Prochain Lab (1.2)
- Sauvegardes **physiques** avec **pgBackRest**
- Restauration à un point dans le temps (**PITR**)
