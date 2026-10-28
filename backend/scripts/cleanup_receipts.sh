#!/bin/sh
# Lamif Kutaa 8 - Receipt Cleanup Script
# Prunes verified receipt images older than 45 days to conserve VPS disk space

RECEIPTS_DIR="/app/uploads/receipts"
if [ ! -d "$RECEIPTS_DIR" ]; then
  RECEIPTS_DIR="$(dirname "$0")/../uploads/receipts"
fi

echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] Starting receipt cleanup in $RECEIPTS_DIR..."

if [ -d "$RECEIPTS_DIR" ]; then
  # Find and remove receipt screenshots modified more than 45 days ago
  DELETED_COUNT=$(find "$RECEIPTS_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) -mtime +45 -print -delete | wc -l)
  echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] Cleaned up $DELETED_COUNT old receipt files (>45 days)."
else
  echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] Directory $RECEIPTS_DIR not found. Skipping."
fi
