#!/bin/bash

###############################################################################
# ArchRampart Audit Tool - Backup Restore Script
# 
# This script restores backed up data
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ArchRampart Audit Tool - Backup Restore               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check backup directory
BACKUP_DIR="${BACKUP_DIR:-./backups}"

if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}✗${NC} Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# List available backups
echo -e "${YELLOW}Available backups:${NC}"
echo ""
BACKUPS=($(ls -td "$BACKUP_DIR"/rampart_backup_* 2>/dev/null | head -10))
if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}✗${NC} No backups found!"
    exit 1
fi

for i in "${!BACKUPS[@]}"; do
    BACKUP_NAME=$(basename "${BACKUPS[$i]}")
    BACKUP_DATE=$(echo "$BACKUP_NAME" | sed 's/rampart_backup_//' | sed 's/_/ /')
    BACKUP_SIZE=$(du -sh "${BACKUPS[$i]}" 2>/dev/null | awk '{print $1}')
    echo -e "  $((i+1)). ${BLUE}${BACKUP_NAME}${NC} (${BACKUP_SIZE}) - ${BACKUP_DATE}"
done
echo ""

# Get backup selection from user
read -p "Select backup number to restore (1-${#BACKUPS[@]}): " SELECTION
SELECTION=$((SELECTION-1))

if [ $SELECTION -lt 0 ] || [ $SELECTION -ge ${#BACKUPS[@]} ]; then
    echo -e "${RED}✗${NC} Invalid selection!"
    exit 1
fi

SELECTED_BACKUP="${BACKUPS[$SELECTION]}"
echo ""
echo -e "${GREEN}✓${NC} Selected backup: ${BLUE}$(basename "$SELECTED_BACKUP")${NC}"
echo ""

# Request confirmation
read -p "This backup will be restored. Do you want to continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "Y" ] && [ "$CONFIRM" != "y" ]; then
    echo "Operation cancelled."
    exit 0
fi
echo ""

# Database settings
DB_NAME="${DB_NAME:-archrampart_audit}"
DB_USER="${DB_USER:-archrampart}"
DB_PASSWORD="${DB_PASSWORD:-archrampart_pass}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"

# 1. DATABASE RESTORE
echo -e "${YELLOW}[1/4]${NC} Restoring database..."

# Find .dump file
DUMP_FILE=$(find "$SELECTED_BACKUP" -name "database_*.dump" | head -1)
SQL_FILE=$(find "$SELECTED_BACKUP" -name "database_*.sql" | head -1)

if [ -n "$DUMP_FILE" ]; then
    echo "  → Custom format (.dump) file found"
    
    # For database in Docker container
    if docker ps | grep -q "postgres"; then
        CONTAINER_NAME=$(docker ps --format "{{.Names}}" | grep -i postgres | head -1)
        if [ -n "$CONTAINER_NAME" ]; then
            docker cp "$DUMP_FILE" "${CONTAINER_NAME}:/tmp/restore.dump"
            docker exec "$CONTAINER_NAME" pg_restore -U "$DB_USER" -d "$DB_NAME" --clean --if-exists "/tmp/restore.dump" || {
                echo -e "  ${YELLOW}⚠${NC} Database restore error (database may already exist)"
            }
            docker exec "$CONTAINER_NAME" rm "/tmp/restore.dump"
            echo -e "  ${GREEN}✓${NC} Database restored"
        fi
    else
        export PGPASSWORD="$DB_PASSWORD"
        pg_restore -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" --clean --if-exists "$DUMP_FILE" 2>/dev/null || {
            echo -e "  ${YELLOW}⚠${NC} Database restore error"
        }
        unset PGPASSWORD
        echo -e "  ${GREEN}✓${NC} Database restored"
    fi
elif [ -n "$SQL_FILE" ]; then
    echo "  → SQL format file found"
    
    if docker ps | grep -q "postgres"; then
        CONTAINER_NAME=$(docker ps --format "{{.Names}}" | grep -i postgres | head -1)
        if [ -n "$CONTAINER_NAME" ]; then
            docker cp "$SQL_FILE" "${CONTAINER_NAME}:/tmp/restore.sql"
            docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" < "/tmp/restore.sql" || {
                echo -e "  ${YELLOW}⚠${NC} Database restore error"
            }
            docker exec "$CONTAINER_NAME" rm "/tmp/restore.sql"
            echo -e "  ${GREEN}✓${NC} Database restored"
        fi
    else
        export PGPASSWORD="$DB_PASSWORD"
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" < "$SQL_FILE" 2>/dev/null || {
            echo -e "  ${YELLOW}⚠${NC} Database restore error"
        }
        unset PGPASSWORD
        echo -e "  ${GREEN}✓${NC} Database restored"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Database backup not found, skipping"
fi
echo ""

# 2. UPLOAD FILES RESTORE
echo -e "${YELLOW}[2/4]${NC} Restoring upload files..."
UPLOADS_BACKUP="${SELECTED_BACKUP}/uploads"
UPLOADS_DIR="${PROJECT_DIR}/backend/uploads"

if [ -d "$UPLOADS_BACKUP" ] && [ "$(ls -A $UPLOADS_BACKUP 2>/dev/null)" ]; then
    mkdir -p "$UPLOADS_DIR"
    cp -r "$UPLOADS_BACKUP"/* "$UPLOADS_DIR/" 2>/dev/null || true
    FILE_COUNT=$(find "$UPLOADS_DIR" -type f 2>/dev/null | wc -l)
    echo -e "  ${GREEN}✓${NC} $FILE_COUNT files restored"
else
    echo -e "  ${YELLOW}⚠${NC} Upload backup not found"
fi
echo ""

# 3. CONFIGURATION FILES RESTORE
echo -e "${YELLOW}[3/4]${NC} Restoring configuration files..."
CONFIG_BACKUP="${SELECTED_BACKUP}/config"

if [ -d "$CONFIG_BACKUP" ]; then
    read -p "  Do you want to restore configuration files? (yes/no): " RESTORE_CONFIG
    if [ "$RESTORE_CONFIG" = "yes" ] || [ "$RESTORE_CONFIG" = "Y" ] || [ "$RESTORE_CONFIG" = "y" ]; then
        # Handle .env file specially
        if [ -f "$CONFIG_BACKUP/backend/.env.backup" ]; then
            read -p "  Do you want to restore .env file? (yes/no): " RESTORE_ENV
            if [ "$RESTORE_ENV" = "yes" ] || [ "$RESTORE_ENV" = "Y" ] || [ "$RESTORE_ENV" = "y" ]; then
                cp "$CONFIG_BACKUP/backend/.env.backup" "${PROJECT_DIR}/backend/.env" 2>/dev/null || true
                echo -e "  ${GREEN}✓${NC} .env file restored"
            fi
        fi
        
        # Restore other configuration files
        rsync -av "$CONFIG_BACKUP/" "$PROJECT_DIR/" --exclude=".env.backup" 2>/dev/null || {
            cp -r "$CONFIG_BACKUP"/* "$PROJECT_DIR/" 2>/dev/null || true
        }
        echo -e "  ${GREEN}✓${NC} Configuration files restored"
    else
        echo -e "  ${YELLOW}⚠${NC} Configuration files skipped"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Configuration backup not found"
fi
echo ""

# 4. INFORMATION
echo -e "${YELLOW}[4/4]${NC} Restore completed!"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            RESTORE COMPLETED!                              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${BLUE}Restart Backend${NC} (to apply changes)"
echo -e "  2. ${BLUE}Restart Frontend${NC} (if necessary)"
echo -e "  3. ${BLUE}Check database connection${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Code files can be restored manually (from code/ directory)"
echo ""
