#!/usr/bin/env bash
# backup.sh - Logical backups with pg_dump (variabilized via .env)
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
conn_args=(-h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}")

mkdir -p "${BACKUP_DIR}"

timestamp=$(date +%Y%m%d_%H%M%S)
base_name="${PGDATABASE}_${timestamp}"

# Flags
dump_format="${DUMP_FORMAT:-c}"
schema_only_flag=""
data_only_flag=""
table_flag=()

if [ "${SCHEMA_ONLY,,}" = "true" ]; then schema_only_flag="--schema-only"; fi
if [ "${DATA_ONLY,,}" = "true" ]; then data_only_flag="--data-only"; fi
if [ -n "${TABLE_FILTER}" ]; then table_flag=(-t "${TABLE_FILTER}"); fi

echo "==> Starting backup of database '${PGDATABASE}' (format=${dump_format})"

case "$dump_format" in
  d|D)
    # Directory format supports parallel dumping (-j)
    out_dir="${BACKUP_DIR}/${base_name}.dir"
    mkdir -p "$out_dir"
    pg_dump "${conn_args[@]}" -F d -j "${JOBS}" ${schema_only_flag} ${data_only_flag} "${table_flag[@]}" -f "$out_dir" "${PGDATABASE}"
    echo "Backup complete: $out_dir"
    echo "$out_dir" > "${BACKUP_DIR}/latest.path"
    ;;
  c|C)
    out_file="${BACKUP_DIR}/${base_name}.dump"
    pg_dump "${conn_args[@]}" -F c ${schema_only_flag} ${data_only_flag} "${table_flag[@]}" -f "$out_file" "${PGDATABASE}"
    echo "Backup complete: $out_file"
    echo "$out_file" > "${BACKUP_DIR}/latest.path"
    ;;
  p|P)
    out_file="${BACKUP_DIR}/${base_name}.sql"
    pg_dump "${conn_args[@]}" -F p ${schema_only_flag} ${data_only_flag} "${table_flag[@]}" -f "$out_file" "${PGDATABASE}"
    echo "Backup complete: $out_file"
    echo "$out_file" > "${BACKUP_DIR}/latest.path"
    ;;
  *)
    echo "ERROR: Unknown DUMP_FORMAT '${dump_format}'. Use c|d|p."
    exit 2
    ;;
esac

echo "Backup finished ✅"
