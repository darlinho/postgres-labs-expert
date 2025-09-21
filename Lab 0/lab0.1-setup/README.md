# Lab 0.1 — Provision & Hygiène système

## Objectif
Préparer un serveur Ubuntu 22.04 pour accueillir PostgreSQL 16 :
- Mise à jour du système
- Répertoires de données sécurisés
- Tuning minimal du noyau
- Sécurisation de l’utilisateur `postgres`
- Pare-feu UFW (SSH seulement)

## Ressources
- 2 serveurs **Medium (2 vCPU / 4 GiB RAM)** : `pg1`, `pg2`

## Utilisation
```bash
./setup_pg_lab01.sh
