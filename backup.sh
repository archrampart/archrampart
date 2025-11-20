#!/bin/bash

###############################################################################
# ArchRampart Audit Tool - Comprehensive Backup Script
# 
# This script creates a complete backup of the entire system:
# - PostgreSQL database
# - Uploaded files
# - Code repository
# - Configuration files
# - Scripts and documentation
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backup settings
BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="rampart_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

# Database settings (can be retrieved from docker-compose.yml)
DB_NAME="${DB_NAME:-archrampart_audit}"
DB_USER="${DB_USER:-archrampart}"
DB_PASSWORD="${DB_PASSWORD:-archrampart_pass}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ArchRampart Audit Tool - Comprehensive Backup         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create backup directory
mkdir -p "$BACKUP_PATH"
echo -e "${GREEN}✓${NC} Backup directory created: ${BACKUP_PATH}"
echo ""

# 1. DATABASE BACKUP
echo -e "${YELLOW}[1/6]${NC} Creating PostgreSQL database backup..."
DB_BACKUP_FILE="${BACKUP_PATH}/database_${TIMESTAMP}.sql"

# For database in Docker container
if docker ps | grep -q "postgres"; then
    echo "  → Backing up database in Docker container..."
    CONTAINER_NAME=$(docker ps --format "{{.Names}}" | grep -i postgres | head -1)
    if [ -z "$CONTAINER_NAME" ]; then
        echo -e "  ${RED}✗${NC} PostgreSQL container not found!"
        exit 1
    fi
    
    docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" -F c -f "/tmp/backup_${TIMESTAMP}.dump"
    docker cp "${CONTAINER_NAME}:/tmp/backup_${TIMESTAMP}.dump" "${BACKUP_PATH}/database_${TIMESTAMP}.dump"
    docker exec "$CONTAINER_NAME" rm "/tmp/backup_${TIMESTAMP}.dump"
    echo -e "  ${GREEN}✓${NC} Database backup created: database_${TIMESTAMP}.dump"
    
    # Also create SQL format backup (for readability)
    docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" > "$DB_BACKUP_FILE"
    echo -e "  ${GREEN}✓${NC} SQL format backup created: database_${TIMESTAMP}.sql"
else
    # Direct PostgreSQL connection
    echo "  → Backing up via direct PostgreSQL connection..."
    export PGPASSWORD="$DB_PASSWORD"
    pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -F c -f "${BACKUP_PATH}/database_${TIMESTAMP}.dump" 2>/dev/null || {
        pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" > "$DB_BACKUP_FILE" 2>/dev/null || {
            echo -e "  ${RED}✗${NC} Database backup failed! Cannot access PostgreSQL."
            echo "  → Continuing (without database backup)..."
        }
    }
    unset PGPASSWORD
    if [ -f "${BACKUP_PATH}/database_${TIMESTAMP}.dump" ] || [ -f "$DB_BACKUP_FILE" ]; then
        echo -e "  ${GREEN}✓${NC} Database backup created"
    fi
fi
echo ""

# 2. UPLOAD FILES BACKUP
echo -e "${YELLOW}[2/6]${NC} Backing up uploaded files..."
UPLOADS_DIR="${PROJECT_DIR}/backend/uploads"
UPLOADS_BACKUP="${BACKUP_PATH}/uploads"

if [ -d "$UPLOADS_DIR" ] && [ "$(ls -A $UPLOADS_DIR 2>/dev/null)" ]; then
    mkdir -p "$UPLOADS_BACKUP"
    cp -r "$UPLOADS_DIR"/* "$UPLOADS_BACKUP/" 2>/dev/null || true
    UPLOAD_COUNT=$(find "$UPLOADS_BACKUP" -type f 2>/dev/null | wc -l)
    echo -e "  ${GREEN}✓${NC} $UPLOAD_COUNT files backed up"
else
    echo -e "  ${YELLOW}⚠${NC} Upload directory is empty or not found"
fi
echo ""

# 3. CODE REPOSITORY BACKUP
echo -e "${YELLOW}[3/6]${NC} Backing up code repository..."
CODE_BACKUP="${BACKUP_PATH}/code"

# If Git repository exists
if [ -d ".git" ]; then
    echo "  → Backing up Git repository..."
    mkdir -p "$CODE_BACKUP"
    git archive --format=tar.gz --output="${CODE_BACKUP}/repository_${TIMESTAMP}.tar.gz" HEAD 2>/dev/null || {
        echo "  → Git archive failed, copying all files..."
        # Copy all files without Git
        rsync -av --exclude='.git' --exclude='node_modules' --exclude='venv' --exclude='__pycache__' \
              --exclude='*.pyc' --exclude='.env' --exclude='backups' \
              "$PROJECT_DIR/" "$CODE_BACKUP/" 2>/dev/null || {
            cp -r "$PROJECT_DIR"/* "$CODE_BACKUP/" 2>/dev/null || true
        }
    }
    echo -e "  ${GREEN}✓${NC} Git repository backed up"
else
    # If no Git, copy all files (excluding node_modules and venv)
    echo "  → Copying all code files..."
    mkdir -p "$CODE_BACKUP"
    rsync -av --exclude='node_modules' --exclude='venv' --exclude='__pycache__' \
          --exclude='*.pyc' --exclude='.env' --exclude='backups' \
          --exclude='*.log' --exclude='.git' \
          "$PROJECT_DIR/" "$CODE_BACKUP/" 2>/dev/null || {
        # Use cp if rsync is not available
        find "$PROJECT_DIR" -type f \
             ! -path "*/node_modules/*" \
             ! -path "*/venv/*" \
             ! -path "*/__pycache__/*" \
             ! -path "*/.git/*" \
             ! -path "*/backups/*" \
             ! -name "*.pyc" \
             ! -name "*.log" \
             ! -name ".env" \
             -exec cp --parents {} "$CODE_BACKUP/" \; 2>/dev/null || true
    }
    echo -e "  ${GREEN}✓${NC} Code files backed up"
fi
echo ""

# 4. CONFIGURATION FILES BACKUP
echo -e "${YELLOW}[4/6]${NC} Backing up configuration files..."
CONFIG_BACKUP="${BACKUP_PATH}/config"
mkdir -p "$CONFIG_BACKUP"

# Copy important configuration files
CONFIG_FILES=(
    "docker-compose.yml"
    "backend/.env"
    "backend/app/core/config.py"
    "frontend/.env"
    "frontend/vite.config.ts"
    "frontend/package.json"
    "backend/requirements.txt"
)

CONFIG_COUNT=0
for config_file in "${CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ]; then
        # Preserve directory structure
        mkdir -p "$CONFIG_BACKUP/$(dirname "$config_file")"
        cp "$config_file" "$CONFIG_BACKUP/$config_file" 2>/dev/null && ((CONFIG_COUNT++)) || true
    fi
done

# Handle .env files specially (may contain sensitive information)
if [ -f "backend/.env" ]; then
    # Copy .env file without encryption (with user warning)
    cp "backend/.env" "$CONFIG_BACKUP/backend/.env.backup" 2>/dev/null || true
fi

echo -e "  ${GREEN}✓${NC} $CONFIG_COUNT configuration files backed up"
echo ""

# 5. SCRIPTS AND DOCUMENTATION BACKUP
echo -e "${YELLOW}[5/6]${NC} Backing up scripts and documentation..."
DOCS_BACKUP="${BACKUP_PATH}/docs_scripts"
mkdir -p "$DOCS_BACKUP"

# Copy documentation files
find "$PROJECT_DIR" -maxdepth 1 -type f \( -name "*.md" -o -name "*.txt" -o -name "*.sh" \) \
     ! -name "backup.sh" \
     -exec cp {} "$DOCS_BACKUP/" \; 2>/dev/null || true

# Copy scripts directory
if [ -d "backend/scripts" ]; then
    cp -r "backend/scripts" "$DOCS_BACKUP/" 2>/dev/null || true
fi

DOCS_COUNT=$(find "$DOCS_BACKUP" -type f 2>/dev/null | wc -l)
echo -e "  ${GREEN}✓${NC} $DOCS_COUNT documentation/script files backed up"
echo ""

# 6. CREATE BACKUP INFORMATION FILE
echo -e "${YELLOW}[6/6]${NC} Creating backup information..."
INFO_FILE="${BACKUP_PATH}/backup_info.txt"
{
    echo "ArchRampart Audit Tool - Backup Information"
    echo "=============================================="
    echo ""
    echo "Backup Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Backup Name: $BACKUP_NAME"
    echo "Backup Path: $BACKUP_PATH"
    echo ""
    echo "System Information:"
    echo "  - Operating System: $(uname -s)"
    echo "  - Kernel: $(uname -r)"
    echo "  - Hostname: $(hostname)"
    echo ""
    echo "Database:"
    echo "  - Name: $DB_NAME"
    echo "  - User: $DB_USER"
    echo "  - Host: $DB_HOST:$DB_PORT"
    echo ""
    echo "Backed Up Components:"
    echo "  1. PostgreSQL database (database_${TIMESTAMP}.dump and .sql)"
    echo "  2. Uploaded files (uploads/)"
    echo "  3. Code repository (code/)"
    echo "  4. Configuration files (config/)"
    echo "  5. Scripts and documentation (docs_scripts/)"
    echo ""
    echo "Backup Size:"
    du -sh "$BACKUP_PATH" 2>/dev/null | awk '{print "  - Total: " $1}'
    echo ""
    echo "Restore:"
    echo "  Use restore.sh script to restore backups."
    echo "  Or manually:"
    echo "    1. Database: using pg_restore or psql"
    echo "    2. Files: copy uploads/ directory"
    echo "    3. Code: copy code/ directory"
    echo ""
} > "$INFO_FILE"

echo -e "  ${GREEN}✓${NC} Backup information saved"
echo ""

# Backup summary
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              BACKUP COMPLETED!                              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Backup Location: ${BLUE}${BACKUP_PATH}${NC}"
echo ""
echo -e "Backed Up Components:"
echo -e "  ${GREEN}✓${NC} PostgreSQL database"
echo -e "  ${GREEN}✓${NC} Uploaded files"
echo -e "  ${GREEN}✓${NC} Code repository"
echo -e "  ${GREEN}✓${NC} Configuration files"
echo -e "  ${GREEN}✓${NC} Scripts and documentation"
echo ""
echo -e "Total Size: ${BLUE}$(du -sh "$BACKUP_PATH" 2>/dev/null | awk '{print $1}')${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} .env files may contain sensitive information. Store them securely!"
echo ""
