#!/bin/bash
set -euo pipefail

# --- config
DATE=$(date +%F)

# directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# backups live in ./db_backups and ./fs_backups relative to the script
DB_BK_DIR="$SCRIPT_DIR/db_backups"
FS_BK_DIR="$SCRIPT_DIR/fs_backups"

DB_NAME="mesquita-prod-18.0"
RETENTION_DAYS=14
FILESTORE_DIR="$HOME/produccion/mesquita-18.0/data/filestore/mesquita-prod-18.0"

# make sure backup dirs exist
mkdir -p "$DB_BK_DIR" "$FS_BK_DIR"

# --- 1) dump database (uses ~/.pgpass if needed)
SQL_FILE="$DB_BK_DIR/db-$DATE.sql"
pg_dump "$DB_NAME" > "$SQL_FILE"

# --- 2) compress with tar+gzip
TAR_DB_FILE="$DB_BK_DIR/db-$DATE.tar.gz"
tar -czf "$TAR_DB_FILE" -C "$DB_BK_DIR" "$(basename "$SQL_FILE")"

echo "[$(date '+%F %T')] Backup DB creado: $TAR_DB_FILE"

# --- 3) remove raw .sql after packaging
rm -f "$SQL_FILE"

# --- 4) compress filestore
if [ -d "$FILESTORE_DIR" ]; then
    TAR_FS_FILE="$FS_BK_DIR/filestore-$DATE.tar.gz"
    tar -czf "$TAR_FS_FILE" -C "$(dirname "$FILESTORE_DIR")" "$(basename "$FILESTORE_DIR")"

    echo "[$(date '+%F %T')] Backup filestore creado: $TAR_FS_FILE"
else
    echo "[$(date '+%F %T')] Advertencia: no se encontró el filestore en $FILESTORE_DIR" >&2
fi

# --- 5) rotate: delete archives older than RETENTION_DAYS
echo "[$(date '+%F %T')] Iniciando rotación de backups. Se eliminarán archivos con más de $RETENTION_DAYS días."

find "$DB_BK_DIR" -type f -name "db-*.tar.gz" -mtime +"$RETENTION_DAYS" -print -delete
find "$FS_BK_DIR" -type f -name "filestore-*.tar.gz" -mtime +"$RETENTION_DAYS" -print -delete