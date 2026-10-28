#!/bin/sh
set -e

echo "[Entrypoint] Running Prisma database migrations..."
npx prisma migrate deploy || echo "[Entrypoint] Warning: prisma migrate deploy exited with non-zero status. Proceeding..."

echo "[Entrypoint] Starting application process..."
exec "$@"
