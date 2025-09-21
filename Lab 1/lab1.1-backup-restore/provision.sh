#!/usr/bin/env bash
# provision.sh - Create a demo database and seed data for Lab 1.1
set -euo pipefail

# Load .env
if [ -f ".env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' .env | grep -E '.+=' -o | xargs) >/dev/null 2>&1 || true
else
  echo "ERROR: .env not found. Copy .env.example to .env and adjust values."
  exit 1
fi

# Respect PGPASSWORD if provided
export PGPASSWORD="${PGPASSWORD:-}"

conn_args=(-h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -v ON_ERROR_STOP=1)

echo "==> Checking if database '${PGDATABASE}' exists..."
DB_EXISTS=$(psql "${conn_args[@]}" -Atqc "SELECT 1 FROM pg_database WHERE datname='${PGDATABASE}'" || echo "")
if [ -z "$DB_EXISTS" ]; then
  echo "==> Creating database '${PGDATABASE}' ..."
  createdb "${conn_args[@]}" "${PGDATABASE}"
else
  echo "==> Database '${PGDATABASE}' already exists."
fi

echo "==> Creating demo schema in '${PGDATABASE}' ..."
psql "${conn_args[@]}" -d "${PGDATABASE}" <<'SQL'
CREATE TABLE IF NOT EXISTS public.products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed minimal data if table is empty
DO $$
BEGIN
  IF (SELECT count(*) FROM public.products) = 0 THEN
    INSERT INTO public.products (name, price) VALUES
      ('Laptop', 1200.50),
      ('Phone', 699.99),
      ('Tablet', 399.00);
  END IF;
END$$;
SQL

echo "==> Verifying data:"
psql "${conn_args[@]}" -d "${PGDATABASE}" -c "TABLE public.products;"

echo "Provisioning completed ✅"
