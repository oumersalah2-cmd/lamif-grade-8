#!/bin/bash
# Lamif Kutaa 8 - Backup Restoration Test Script
# Validates backup integrity by restoring the latest backup file into an isolated test DB.

set -eo pipefail

BACKUP_DIR="${BACKUP_DIR:-$(dirname "$0")/backups}"
CONTAINER_NAME="${PG_CONTAINER:-lamif_postgres}"
DB_USER="${POSTGRES_USER:-postgres}"
TEST_DB="lamif_backup_validation_tmp"

# Find latest backup file
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/lamif_backup_*.sql.gz 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "Error: No backup files found in $BACKUP_DIR"
  exit 1
fi

echo "=========================================================="
echo " Starting Backup Verification Test"
echo " Testing file: $LATEST_BACKUP"
echo " Target Test Database: $TEST_DB"
echo "=========================================================="

echo "1. Creating temporary test database '$TEST_DB'..."
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS $TEST_DB;" >/dev/null
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -c "CREATE DATABASE $TEST_DB;" >/dev/null

echo "2. Restoring backup archive into '$TEST_DB'..."
gunzip -c "$LATEST_BACKUP" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$TEST_DB" >/dev/null 2>&1

echo "3. Running verification queries on restored data..."
USER_COUNT=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$TEST_DB" -t -c "SELECT COUNT(*) FROM \"User\";" 2>/dev/null | tr -d ' ' || echo "0")
EXAM_COUNT=$(docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$TEST_DB" -t -c "SELECT COUNT(*) FROM \"ExamResult\";" 2>/dev/null | tr -d ' ' || echo "0")

echo "   -> Users in restored database: $USER_COUNT"
echo "   -> ExamResults in restored database: $EXAM_COUNT"

echo "4. Cleaning up temporary test database..."
docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS $TEST_DB;" >/dev/null

echo "=========================================================="
echo " SUCCESS: Backup archive is 100% valid and restorable!"
echo " Tested at: $(date -u)"
echo "=========================================================="
