#!/usr/bin/env bash
# restore.sh - Restore a backup into RESTORE_DATABASE (variabilized via .env)
set -euo pipefail

# Load .env
if [ -f ".env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' .env | grep -E '.+=' -o | xargs) >/dev/null 2>&1 || true
else
  echo "ERROR: .env not found. Copy .env.example to .env and adjust values."
  exit 1
fi

export PGPASSWORD="${PGPASSWORD:-}"
conn_args=(-h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -v ON_ERROR_STOP=1)

BACKUP_INPUT="${1:-}"
if [ -z "${BACKUP_INPUT}" ]; then
  if [ -f "${BACKUP_DIR}/latest.path" ]; then
    BACKUP_INPUT="$(cat "${BACKUP_DIR}/latest.path")"
    echo "==> Using latest backup: ${BACKUP_INPUT}"
  else
    echo "Usage: $0 <backup_file_or_directory>"
    echo "       Or ensure ${BACKUP_DIR}/latest.path exists."
    exit 2
  fi
fi

# Ensure target database exists
DB_EXISTS=$(psql "${conn_args[@]}" -Atqc "SELECT 1 FROM pg_database WHERE datname='${RESTORE_DATABASE}'" || echo "")
if [ -z "$DB_EXISTS" ]; then
  echo "==> Creating database '${RESTORE_DATABASE}' ..."
  createdb "${conn_args[@]}" "${RESTORE_DATABASE}"
else
  echo "==> Database '${RESTORE_DATABASE}' already exists."
fi

# Optional table filter
table_flag=()
if [ -n "${TABLE_FILTER}" ]; then table_flag=(-t "${TABLE_FILTER}"); fi

echo "==> Restoring into '${RESTORE_DATABASE}' from '${BACKUP_INPUT}'"
if [ -d "${BACKUP_INPUT}" ]; then
  # Directory format (-Fd)
  pg_restore -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${RESTORE_DATABASE}" -j "${JOBS}" "${table_flag[@]}" "${BACKUP_INPUT}"
elif [[ "${BACKUP_INPUT}" == *.dump ]]; then
  # Custom format (-Fc)
  pg_restore -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${RESTORE_DATABASE}" -j "${JOBS}" "${table_flag[@]}" "${BACKUP_INPUT}"
elif [[ "${BACKUP_INPUT}" == *.sql ]]; then
  # Plain SQL (-Fp)
  psql -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${RESTORE_DATABASE}" -f "${BACKUP_INPUT}"
else
  echo "ERROR: Unknown backup type for '${BACKUP_INPUT}'. Expect directory, .dump, or .sql"
  exit 3
fi

echo "==> Basic verification:"
psql "${conn_args[@]}" -d "${RESTORE_DATABASE}" -c "SELECT now() as restored_at;"
# If products table exists, show row count (best-effort)
psql "${conn_args[@]}" -d "${RESTORE_DATABASE}" -c "SELECT 'products' AS table, count(*) FROM public.products;" || true

echo "Restore completed ✅"
