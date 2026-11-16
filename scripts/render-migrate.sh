#!/bin/bash
# Render pre-deploy migration for Baba Farid Mobiles backend.
# Runs before every deploy. schema.sql is NOT idempotent, so it is applied
# only once (when the users table does not exist yet). The catalog migration
# and seed.sql ARE idempotent (ON CONFLICT / IF NOT EXISTS), so they run
# on every deploy safely.
# Requires: psql (installed by render.yaml buildCommand) and DATABASE_URL.
set -e
cd "$(dirname "$0")/.."

if ! psql "$DATABASE_URL" -tAc "SELECT to_regclass('public.users')" | grep -q users; then
  echo "Applying database/schema.sql (first deploy)..."
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f database/schema.sql
else
  echo "Schema already present — skipping database/schema.sql"
fi

echo "Applying database/migrations/001_accessories_catalog.sql..."
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f database/migrations/001_accessories_catalog.sql

echo "Applying database/seed.sql (idempotent)..."
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f database/seed.sql

echo "Migration complete."
