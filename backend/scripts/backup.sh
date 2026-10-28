#!/bin/bash
# Lamif Kutaa 8 - Automated 3-Hour Database Backup Script
# Performs compressed pg_dump from container and rotates backups older than 7 days

set -eo pipefail

BACKUP_DIR="${BACKUP_DIR:-/backups}"
if [ ! -d "$BACKUP_DIR" ]; then
  BACKUP_DIR="$(dirname "$0")/backups"
  mkdir -p "$BACKUP_DIR"
fi

TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S")
FILENAME="$BACKUP_DIR/lamif_backup_$TIMESTAMP.sql.gz"

CONTAINER_NAME="${PG_CONTAINER:-lamif_postgres}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-lamif_kutaa_8}"

echo "[$TIMESTAMP] Starting database backup for $DB_NAME..."

# Execute pg_dump inside container and pipe to gzip
if command -v docker >/dev/null 2>&1; then
  docker exec -t "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" | gzip -9 > "$FILENAME"
else
  # Direct pg_dump if executed on the database host
  pg_dump -U "$DB_USER" -d "$DB_NAME" | gzip -9 > "$FILENAME"
fi

FILESIZE=$(ls -lh "$FILENAME" | awk '{print $5}')
echo "[$TIMESTAMP] Backup successfully created at $FILENAME ($FILESIZE)"

# Prune backups older than 7 days (56 backups at 3-hour frequency)
echo "[$TIMESTAMP] Pruning backups older than 7 days..."
find "$BACKUP_DIR" -type f -name "lamif_backup_*.sql.gz" -mtime +7 -delete

echo "[$TIMESTAMP] Backup and retention cycle completed."
